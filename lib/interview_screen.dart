import 'package:flutter/material.dart';
import 'data.dart';

class InterviewScreen extends StatefulWidget {
  final String roleTitle;

  const InterviewScreen({super.key, required this.roleTitle});

  @override
  _InterviewScreenState createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final List<Map<String, String>> _questions = [];
  final List<String> _userResponses = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _responseController = TextEditingController();
  bool _isInterviewComplete = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    // Find the role in AppData.roles based on roleTitle
    final role = AppData.roles.firstWhere((r) => r["title"] == widget.roleTitle);
    final description = role["description"]!;
    
    // Extract key topics from the description (split by newlines and filter out empty lines)
    final topics = description.split('\n').where((line) => line.trim().startsWith('-')).map((line) => line.trim().substring(2).trim()).toList();

    // Generate questions based on topics
    setState(() {
      for (var topic in topics) {
        _questions.add({"question": "Can you explain your experience with $topic?"});
      }
      // Add a generic closing question
      _questions.add({"question": "Why do you think you’re a good fit for ${widget.roleTitle}?"});
    });
  }

  void _submitResponse() {
    if (_responseController.text.isNotEmpty) {
      setState(() {
        _userResponses.add(_responseController.text);
        _responseController.clear();
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          _isInterviewComplete = true;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a response before proceeding.")),
      );
    }
  }

  void _generateResponseSheet() {
    // Generate a response sheet with mock AI evaluation
    String responseSheet = "Interview Response Sheet for ${widget.roleTitle}\n\n";
    for (int i = 0; i < _questions.length; i++) {
      responseSheet += "Q${i + 1}: ${_questions[i]['question']}\n";
      responseSheet += "A: ${_userResponses[i]}\n\n";
    }
    
    // Mock AI evaluation based on response length (could be replaced with real AI analysis)
    String evaluation = "Evaluation:\n";
    double avgResponseLength = _userResponses.fold(0, (sum, response) => sum + response.length) / _userResponses.length;
    if (avgResponseLength > 50) {
      evaluation += "Your responses are detailed and thoughtful, indicating strong preparation for ${widget.roleTitle}. Great job!";
    } else {
      evaluation += "Your responses are concise but could benefit from more detail to fully showcase your skills for ${widget.roleTitle}.";
    }
    
    responseSheet += evaluation;

    // Show the response sheet in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Response Sheet"),
        content: SingleChildScrollView(
          child: Text(responseSheet),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to RoleDetailScreen
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
      appBar: AppBar(
        title: Text("AI Interview - ${widget.roleTitle}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isInterviewComplete
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
                  Text(
                    _questions[_currentQuestionIndex]["question"]!,
                    style: const TextStyle(fontSize: 16),
                  ),
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
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? "Finish"
                              : "Next Question",
                        ),
                      ),
                    ],
                  ),
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