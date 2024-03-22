import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_model.dart';
import 'api_services.dart';

class ChatMessage {
  String text;
  ChatMessageType type;

  ChatMessage({required this.text, required this.type});

  String toJson() {
    return json.encode({'text': text, 'type': type.index});
  }

  static ChatMessage fromJson(String jsonString) {
    var jsonData = json.decode(jsonString);
    return ChatMessage(
        text: jsonData['text'], type: ChatMessageType.values[jsonData['type']]);
  }
}

class ChatScreen extends StatefulWidget {
  static String routeName = "/chat";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ApiServices _apiServices = ApiServices(); 

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _speech = stt.SpeechToText();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringMessages = _messages.map((m) => m.toJson()).toList();
    await prefs.setStringList('chat_messages', stringMessages);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringMessages = prefs.getStringList('chat_messages') ?? [];
    _messages = stringMessages.map((m) => ChatMessage.fromJson(m)).toList();
    setState(() {});  
  }

  Future<void> _clearMessages() async {
    setState(() {
      _messages.clear();
    });
    await _saveMessages();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (val) => print('onError: $val'),
      onStatus: (val) => print('onStatus: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _textController.text = val.recognizedWords;
        }),
        localeId: 'ko_KR',
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _handleSubmitted(_textController.text);
      _textController.clear();
      setState(() => _isListening = false);
    }
  }

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();

    ChatMessage message = ChatMessage(
      text: text,
      type: ChatMessageType.user,
    );

    setState(() {
      _messages.add(message);
    });

    _saveMessages();  

    var response = await _apiServices.sendMessage(text);
    if (response != null) {
      setState(() {
        _messages.add(
            ChatMessage(text: response, type: ChatMessageType.bot));
      });
      _saveMessages();  
    }

    _apiServices.sendBackgroundMessage(text);
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: _clearMessages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot")),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemBuilder: (_, int index) =>
                  _buildChatMessage(_messages[index]),
              itemCount: _messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.type == ChatMessageType.user
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          message.type == ChatMessageType.bot
              ? Icon(Icons.android)
              : Container(),
          Flexible(
            child: Column(
              crossAxisAlignment: message.type == ChatMessageType.user
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.type == ChatMessageType.bot ? "Bot" : "User",
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Text(
                    message.text,
                  ),
                ),
              ],
            ),
          ),
          message.type == ChatMessageType.user
              ? Icon(Icons.person)
              : Container(),
        ],
      ),
    );
  }
}






