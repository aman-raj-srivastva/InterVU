from flask import Flask, request, jsonify
from flask_socketio import SocketIO
import cv2
import mediapipe as mp
import numpy as np
from vosk import Model, KaldiRecognizer
import base64
import threading

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# Load Vosk model for speech recognition
model = Model("model")
recognizer = KaldiRecognizer(model, 16000)

# Initialize MediaPipe face detection
mp_face_detection = mp.solutions.face_detection
face_detection = mp_face_detection.FaceDetection(min_detection_confidence=0.5)

def analyze_video_frame(frame):
    # Convert frame to RGB for MediaPipe
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = face_detection.process(rgb_frame)

    confidence_score = 0
    cheating_detected = False

    if results.detections:
        for detection in results.detections:
            confidence_score = detection.score[0]

            # Detect cheating (e.g., looking away from the screen)
            bbox = detection.location_data.relative_bounding_box
            if bbox.xmin < 0.2 or bbox.xmax > 0.8 or bbox.ymin < 0.2 or bbox.ymax > 0.8:
                cheating_detected = True

    return confidence_score, cheating_detected

def analyze_audio_chunk(audio_data):
    if recognizer.AcceptWaveform(audio_data):
        result = json.loads(recognizer.Result())
        return result.get("text", "")
    return ""

@socketio.on("video_frame")
def handle_video_frame(data):
    # Decode base64 video frame
    frame_data = base64.b64decode(data["frame"])
    frame = cv2.imdecode(np.frombuffer(frame_data, dtype=np.uint8), cv2.IMREAD_COLOR)

    # Analyze video frame
    confidence_score, cheating_detected = analyze_video_frame(frame)

    # Send feedback to the client
    socketio.emit("video_feedback", {
        "confidence_score": confidence_score,
        "cheating_detected": cheating_detected,
    })

@socketio.on("audio_chunk")
def handle_audio_chunk(data):
    # Analyze audio chunk
    transcript = analyze_audio_chunk(data["audio"])

    # Send feedback to the client
    socketio.emit("audio_feedback", {
        "transcript": transcript,
    })

if __name__ == "__main__":
    socketio.run(app, host="0.0.0.0", port=5000)