import 'package:flutter/material.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class SharedCalenderScreen extends StatefulWidget {
  static String routeName = "/shared_calendar";

  const SharedCalenderScreen({Key? key}) : super(key: key);

  @override
  _SharedCalendarScreenState createState() => _SharedCalendarScreenState();
}

class _SharedCalendarScreenState extends State<SharedCalenderScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    fetchEventsFromServer();
  }

  Future<void> fetchEventsFromServer() async {
    List<String> endpoints = [
      'http://URL:3001/receive-message',
      'http://URL:4000/messages',
    ];

    for (var endpoint in endpoints) {
      try {
        final url = Uri.parse(endpoint);
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final List<dynamic> fetchedData = json.decode(response.body);
          for (var dataItem in fetchedData) {
            final String jsonString = dataItem['message'];
            final Map<String, dynamic> item = json.decode(jsonString);
            if (item.containsKey('shared calendar event')) {
              final List<dynamic> eventDetails = item['shared calendar event'];
              final String date = eventDetails[0];
              final String eventName = eventDetails[1];
              final DateTime eventDate = DateTime.parse(date);
              final DateTime eventDateWithoutTime = DateTime.utc(eventDate.year, eventDate.month, eventDate.day);

              if (!_events.containsKey(eventDateWithoutTime)) {
                _events[eventDateWithoutTime] = [];
              }
              _events[eventDateWithoutTime]?.add({
                'id': dataItem['id'], // ID 추가
                'name': eventName,
              });
            }
          }
          setState(() {});
        }
      } catch (e) {
        print('Error fetching events from $endpoint: $e');
      }
    }
  }

  void addEvent(BuildContext context, String eventName) async {
    final DateTime eventDate = _selectedDay!;
    final String formattedDate = "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}";
    final Map<String, dynamic> event = {
      'shared calendar event': [formattedDate, eventName],
    };

    final response = await http.post(
      Uri.parse('http://URL:3001/receive-message'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'message': jsonEncode(event)}),
    );

    if (response.statusCode == 200) {
      fetchEventsFromServer(); // 이벤트 추가 후 상태 업데이트
    } else {
      print("Failed to add the event on the server. Status code: ${response.statusCode}");
    }
  }

void deleteEvent(String eventId) async {
  // 현재 시스템 (Flutter 앱이 연결된 서버)에서 이벤트 삭제
  final currentSystemUrl = 'http://URL:3001/delete-message/$eventId';
  print('Sending delete request to current system: $currentSystemUrl');

  final response = await http.delete(Uri.parse(currentSystemUrl));

  if (response.statusCode == 200) {
    print("Event deleted successfully on the current system.");
    setState(() {
      // 현재 시스템에서 이벤트가 성공적으로 삭제된 경우, UI 상에서도 해당 이벤트를 제거
      _events.removeWhere((date, events) => events.any((event) => event['id'] == eventId));
    });

    // 다른 시스템에도 삭제 요청 전파
    final otherSystemUrl = 'http://URL/delete-message/$eventId';
    print('Forwarding delete request to the other system: $otherSystemUrl');
    final otherResponse = await http.delete(Uri.parse(otherSystemUrl));

    if (otherResponse.statusCode == 200) {
      print("Event also deleted in the other system.");
    } else {
      print("Failed to delete the event in the other system. Status code: ${otherResponse.statusCode}");
      // 필요한 경우, 사용자에게 실패에 대한 피드백 제공
    }
  } else {
    print("Failed to delete the event on the current system. Status code: ${response.statusCode}, Response body: ${response.body}");
    // 현재 시스템에서의 응답이 실패인 경우, 사용자에게 알림 표시
    final String errorMessage = json.decode(response.body)['message'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error Deleting Event"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[day]?.map((e) => e['name']).toList() ?? [];
            },
          ),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialogToAddEvent(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _events[_selectedDay] ?? [];
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          child: ListTile(
            title: Text(event['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteEvent(event['id']),
            ),
          ),
        );
      },
    );
  }

  void showDialogToAddEvent(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Event"),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Enter event name"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Add"),
            onPressed: () {
              final eventName = _controller.text.trim();
              if (eventName.isNotEmpty) {
                addEvent(context, eventName);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
