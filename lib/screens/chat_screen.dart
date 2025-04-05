import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  static var apiKey = dotenv.env['GEMINI_API_KEY'];
  final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
  Map<String, dynamic>? _userProfile;
  bool _isGenerating = false;
  bool _shouldStop = false;

  final FlutterTts _flutterTts = FlutterTts();
  List<String> _speechChunks = [];
  int _currentChunkIndex = 0;
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _lastResponse = "";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _addWelcomeMessage();
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

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'sender': 'ai',
        'text': 'Namaste! I am Rupee Guru, your financial assistant for beginners in India. How can I help you today?',
        'richText': _parseMarkdownToRichText('Namaste! I am Rupee Guru, your financial assistant for beginners in India. How can I help you today?'),
        'interrupted': false,
      });
    });
  }

  String createPrompt(String userMessage) {
    String basePrompt = "You are a financial assistant for beginners in India and your name is Rupee Guru. "
        "Answer the following question in simple terms, avoiding complex jargon. "
        "Do not say 'Namaste' in your response, as you have already greeted the user. "
        "Don't always say hi there in your responses when something is asked. "
        "Use **text** to indicate bold text in your response: $userMessage";

    if (_userProfile != null) {
      String goals = _userProfile!['goals'] ?? 'not specified';
      String risk = _userProfile!['risk_preference'] ?? 'not specified';
      return "The user has the following financial goals: $goals. "
          "Their risk preference is: $risk. "
          "$basePrompt";
    }
    return basePrompt;
  }

  RichText _parseMarkdownToRichText(String text) {
    if (text.isEmpty) {
      return RichText(text: TextSpan(text: ''));
    }

    List<TextSpan> spans = [];
    RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty && !_isGenerating) {
      String userMessage = _messageController.text;
      setState(() {
        _messages.add({'sender': 'user', 'text': userMessage});
        _messageController.clear();
        _isGenerating = true;
        _shouldStop = false;
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
          String aiResponse = data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response text';
          await _typeMessage(aiResponse);
        } else {
          await _typeMessage('Error: Unable to get response (Status: ${response.statusCode})');
        }
      } catch (e) {
        await _typeMessage('Error: Something went wrong - $e');
      }

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _stopGeneration() async {
    setState(() {
      _shouldStop = true;
      _isGenerating = false;
      if (_messages.isNotEmpty && _messages.last['sender'] == 'ai') {
        _messages.last['interrupted'] = true;
      }
    });
  }

  Future<void> _typeMessage(String message) async {
    String typedText = '';
    setState(() {
      _messages.add({'sender': 'ai', 'text': typedText, 'richText': _parseMarkdownToRichText(''), 'interrupted': false});
    });

    for (int i = 0; i < message.length && !_shouldStop; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      if (mounted) {
        setState(() {
          typedText += message[i];
          _messages.last['text'] = typedText;
          _messages.last['richText'] = _parseMarkdownToRichText(typedText);
        });
      }
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }

    _lastResponse = message;
    _speechChunks = _splitIntoChunks(_lastResponse);
    _currentChunkIndex = 0;
    _isPaused = false;
  }

  List<String> _splitIntoChunks(String text) {
    return text.split(RegExp(r'(?<=[.?!])\s+')).where((e) => e.trim().isNotEmpty).toList();
  }

  Future<void> _speakResponse() async {
    if (_speechChunks.isEmpty || _currentChunkIndex >= _speechChunks.length) return;

    _isSpeaking = true;
    _isPaused = false;

    // Set language to English (India)
    await _flutterTts.setLanguage("en-IN");

    _flutterTts.setCompletionHandler(() {
      if (_isPaused) return;
      _currentChunkIndex++;
      if (_currentChunkIndex < _speechChunks.length) {
        _flutterTts.speak(_speechChunks[_currentChunkIndex]);
      } else {
        _isSpeaking = false;
        setState(() {});
      }
    });

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });

    await _flutterTts.speak(_speechChunks[_currentChunkIndex]);
  }

  Future<void> _pauseSpeech() async {
    await _flutterTts.stop();
    _isPaused = true;
    _isSpeaking = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Rupee Guru", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 4,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  final isLastAI = !isUser && index == _messages.length - 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? 'You' : 'Rupee Guru',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isUser
                                  ? Text(message['text'], style: const TextStyle(fontSize: 16, color: Colors.black))
                                  : (message['richText'] as RichText?) ?? Text(message['text'], style: const TextStyle(fontSize: 16, color: Colors.black)),
                              if (!isUser && message['interrupted'] == true)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Response interrupted',
                                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              if (isLastAI && !_isGenerating)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow),
                                    onPressed: _isSpeaking ? _pauseSpeech : _speakResponse,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isGenerating ? Colors.red[800] : const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(_isGenerating ? Icons.stop : Icons.send),
                      color: Colors.white,
                      onPressed: _isGenerating ? _stopGeneration : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
