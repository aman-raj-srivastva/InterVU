from flask import Flask, request, jsonify
from transformers import DistilBertTokenizer, DistilBertForQuestionAnswering
import torch

app = Flask(__name__)

# Load the DistilBERT model and tokenizer
tokenizer = DistilBertTokenizer.from_pretrained("distilbert-base-uncased")
model = DistilBertForQuestionAnswering.from_pretrained("distilbert-base-uncased")

# Mock role data (replace with actual data from your Flutter app)
role_data = {
    "Software Engineer": {
        "description": (
            "Software Engineers design, develop, and maintain software systems. "
            "Key topics to prepare for include:\n\n"
            "- Data Structures & Algorithms\n"
            "- System Design\n"
            "- Object-Oriented Programming\n"
            "- Database Management\n"
            "- Problem-Solving Skills"
        )
    }
}

def generate_questions(description):
    # Simple heuristic to generate questions from description (fine-tuning would improve this)
    topics = [line.strip()[2:] for line in description.split('\n') if line.strip().startswith('-')]
    questions = [f"Can you explain your experience with {topic}?" for topic in topics]
    questions.append(f"Why do you think you’re a good fit for this role?")
    return questions

def evaluate_response(question, response):
    # Mock evaluation using DistilBERT (fine-tuning needed for real accuracy)
    inputs = tokenizer(question, response, return_tensors="pt", truncation=True, padding=True)
    with torch.no_grad():
        outputs = model(**inputs)
    score = torch.softmax(outputs.logits, dim=1)[0][1].item()  # Simplified confidence score
    feedback = "Good response, but consider adding more detail." if score < 0.7 else "Excellent response!"
    return {"score": score, "feedback": feedback}

@app.route('/start_interview', methods=['POST'])
def start_interview():
    data = request.json
    role_title = data.get("role_title")
    description = role_data.get(role_title, {}).get("description", "")
    questions = generate_questions(description)
    return jsonify({"questions": questions})

@app.route('/evaluate_response', methods=['POST'])
def evaluate_response():
    data = request.json
    question = data.get("question")
    response = data.get("response")
    evaluation = evaluate_response(question, response)
    return jsonify(evaluation)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)