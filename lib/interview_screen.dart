import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'data.dart';

class InterviewScreen extends StatefulWidget {
  final String roleTitle;

  const InterviewScreen({super.key, required this.roleTitle});

  @override
  _InterviewScreenState createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  List<Map<String, String>> _questions = [];
  final List<String> _userResponses = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _responseController = TextEditingController();
  bool _isInterviewComplete = false;
  String _evaluationFeedback = "";

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final url = Uri.parse('http://localhost:5000/start_interview'); // Update with your backend URL
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"role_title": widget.roleTitle}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _questions = List<Map<String, String>>.from(data["questions"].map((q) => {"question": q}));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load questions")),
      );
    }
  }

  Future<void> _submitResponse() async {
    if (_responseController.text.isNotEmpty) {
      final url = Uri.parse('http://localhost:5000/evaluate_response'); // Update with your backend URL
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": _questions[_currentQuestionIndex]["question"],
          "response": _responseController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userResponses.add(_responseController.text);
          _evaluationFeedback = data["feedback"];
          _responseController.clear();
          if (_currentQuestionIndex < _questions.length - 1) {
            _currentQuestionIndex++;
          } else {
            _isInterviewComplete = true;
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a response")),
      );
    }
  }

  void _generateResponseSheet() {
    String responseSheet = "Interview Response Sheet for ${widget.roleTitle}\n\n";
    for (int i = 0; i < _questions.length; i++) {
      responseSheet += "Q${i + 1}: ${_questions[i]['question']}\n";
      responseSheet += "A: ${_userResponses[i]}\n\n";
    }
    responseSheet += "Evaluation: $_evaluationFeedback";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Response Sheet"),
        content: SingleChildScrollView(child: Text(responseSheet)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Interview - ${widget.roleTitle}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _questions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _isInterviewComplete
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Interview Complete!",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generateResponseSheet,
                          child: const Text("Generate Response Sheet"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: Colors.grey[300],
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(_questions[_currentQuestionIndex]["question"]!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _responseController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Your Response",
                          hintText: "Type your answer here...",
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentQuestionIndex > 0)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentQuestionIndex--;
                                  _responseController.text = _userResponses[_currentQuestionIndex];
                                });
                              },
                              child: const Text("Previous"),
                            ),
                          ElevatedButton(
                            onPressed: _submitResponse,
                            child: Text(_currentQuestionIndex == _questions.length - 1 ? "Finish" : "Next Question"),
                          ),
                        ],
                      ),
                      if (_evaluationFeedback.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text("Feedback: $_evaluationFeedback", style: const TextStyle(color: Colors.green)),
                      ],
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
}