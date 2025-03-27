import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  static const String apiKey = 'AIzaSyB-GRQ2C-XykwZcXv3e1HuMjgnPZjhxzdI'; // Replace with your real Gemini API key
  final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userProfile = doc.data();
        });
      }
    }
  }

  String createPrompt(String userMessage) {
    String basePrompt = "You are a financial assistant for beginners in India. "
        "Answer the following question in simple terms, avoiding complex jargon: $userMessage";

    if (_userProfile != null) {
      String goals = _userProfile!['goals'] ?? 'not specified';
      String risk = _userProfile!['risk_preference'] ?? 'not specified';
      return "The user has the following financial goals: $goals. "
          "Their risk preference is: $risk. "
          "$basePrompt";
    }
    return basePrompt;
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String userMessage = _messageController.text;
      setState(() {
        _messages.add({'sender': 'user', 'text': userMessage});
        _messageController.clear();
      });

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': createPrompt(userMessage)}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
          setState(() {
            _messages.add({'sender': 'ai', 'text': aiResponse});
          });
        } else {
          setState(() {
            _messages.add({'sender': 'ai', 'text': 'Error: Unable to get response'});
          });
        }
      } catch (e) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': 'Error: $e'});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['text']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your question...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}