import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shop_app/screens/home/home_screen.dart'; // 경로는 실제 프로젝트에 맞게 조정하세요.

class VoicemailScreen extends StatefulWidget {
  static String routeName = "/voicemail";

  const VoicemailScreen({Key? key}) : super(key: key);

  @override
  _VoicemailScreenState createState() => _VoicemailScreenState();
}

class _VoicemailScreenState extends State<VoicemailScreen> {
  List<Map<String, dynamic>> messages = []; // 메시지 목록을 관리하는 변수
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    fetchMessages();
    initializeTts();
  }

  void initializeTts() {
    flutterTts.setLanguage("ko-KR");
    flutterTts.setStartHandler(() {
      print("Playing");
    });
    flutterTts.setCompletionHandler(() {
      print("Complete");
    });
    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
    });
  }

Future<void> fetchMessages() async {
  const url = 'http://URL:3001/receive-message';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> loadedMessages = [];
      for (var item in data) {
        // 메시지 디코드하기 전에 null 체크
        var messageContent = item['message'] != null ? json.decode(item['message']) : null;
        if (messageContent != null && messageContent.containsKey('greeting message')) {
          loadedMessages.add({
            'id': item['id'], // 메시지의 고유 ID
            'message': messageContent['greeting message'], // 실제 메시지 내용
          });
        }
      }
      setState(() {
        messages = loadedMessages;
      });
    } else {
      print('Failed to load messages');
    }
  } catch (e) {
    print('Error fetching messages: $e');
  }
}


  Future<void> speak(String message) async {
    await flutterTts.speak(message);
  }

  void deleteMessage(String messageId, int index) async {
    final response = await http.delete(
      Uri.parse('http://URL:3001/delete-message/$messageId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print("Message deleted successfully on the server.");
      setState(() {
        messages.removeAt(index);
      });
    } else {
      print("Failed to delete the message. Status code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          child: SizedBox(
            width: 125,
            height: 70,
            child: Image.asset('assets/images/poom_app_logo.png', fit: BoxFit.contain),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: messages.isEmpty
            ? Text("No greeting messages available.")
            : ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        messages[index]['message'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak(messages[index]['message']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteMessage(messages[index]['id'], index),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
