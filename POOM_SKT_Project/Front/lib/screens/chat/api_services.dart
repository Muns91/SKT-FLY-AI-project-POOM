import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert'; // JSON 인코딩/디코딩을 위해 필요
// import 'package:shop_app/screens/chat/chat_model.dart';

class ApiServices {
  final OpenAI _openAI = OpenAI.instance.build(
    token:
        'Your Token', // 실제 사용하는 토큰으로 대체해야 함
    baseOption: HttpSetup(
      receiveTimeout: Duration(seconds: 60),
      connectTimeout: Duration(seconds: 30),),
    
    enableLog: true,
  );


  // 컴퓨터 A에서 실행되는 백엔드 서버의 URL
  final String _backendUrl = 'URL:4000'; // 본인 서버

  // 사용자로부터 메시지를 받아 GPT-3 챗봇에 전송하고 응답을 반환하는 함수
  Future<String?> sendMessage(String? message) async {
    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {"role": "user", "content": message}
      ],
      maxToken: 200,
    );
    print('Sending request: ${jsonEncode(request.toJson())}');
    final response = await _openAI.onChatCompletion(request: request);

    if (response != null &&
        response.choices.isNotEmpty &&
        response.choices.first.message != null) {
      String botResponse = response.choices.first.message!.content;
      // 사용자 메시지와 봇 응답을 서버로 전송
      _sendChatMessageToServer(message, botResponse);
      return botResponse;
    } else {
      return "I'm sorry, I couldn't process your message.";
    }
  }

  // 백그라운드에서 메시지를 처리하고 결과를 서버로 전송하는 함수
  Future<void> sendBackgroundMessage(String message) async {
    // 현재 날짜를 "yyyy-MM-dd" 포맷으로 변환
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String customPrompt = "Given the user's message: \"$message\", "
        "You are a butler in senior care who brokers two-way communication between parents and children. \n\n"
        "You extract the important parts of what I type and generate only one of the following: greeting, calendar, or wish list.\n\n"
        "For example, if what I say includes an object, creature, or thing, it sends it as a wish list; if I enter a date, it identifies the year, month, day, and to-do and sends it as a calendar; or if it identifies a concern, news, or intention, \n\n"
        "it summarizes what the user said and sends it as a greeting, as if the user had said it. All responses are available in Korean. \n\n"
        "The form is also delivered in JSON format so that you can send and receive forwarding input on the backend.\n\n"
        "Especially for dates, if the year, month, and day are missing based on the date you responded "
        "You can fill in the missing pieces based on today, and if you have the words today, next week, next Monday, next Tuesday, next Wednesday,"
        "You can fill in based on $formattedDate when responding with next Thursday, next Friday, next Saturday, next Sunday, the day after tomorrow, etc.\n\n"
        "{\"wishlist\": \"item name\"}, {\"shared calendar event\" : [\"yyyy-mm-dd\", \"todo\"]}, {\"greeting message\": \"intent\"}";
    // 커스텀 프롬프트 계속...

    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {"role": "system", "content": customPrompt}
      ],
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);

 if (response != null &&
    response.choices.isNotEmpty &&
    response.choices.first.message != null) {
  String output = response.choices.first.message!.content;
  print('GPT Output: $output');

  // JSON 형식 확인 및 파싱
  Map<String, dynamic> parsedOutput;
  try {
    parsedOutput = json.decode(output);
  } catch (e) {
    print('Output is not valid JSON. Error: $e');
    return;
  }

  String jsonBody;
  String endpoint;

  // "/wishlist" 엔드포인트 별도 처리
  if (parsedOutput.containsKey('wishlist')) {
    // 'wishlist' 항목이 있으면, 해당 정보로 JSON 본문을 구성
    jsonBody = jsonEncode({"message": output});
    endpoint = '$_backendUrl/wishlist'; // "/wishlist" 엔드포인트 설정
  } else {
    // 기타 조건들은 "send-message" 엔드포인트로 메시지 전송
    jsonBody = jsonEncode({"message": output}); // 기본 메시지 포맷 사용
    endpoint = '$_backendUrl/send-message'; // 기본 엔드포인트 설정
  }

  // HTTP POST 요청 전송
  final httpResponse = await http.post(
    Uri.parse(endpoint), // 조건에 따라 결정된 엔드포인트 사용
    headers: {"Content-Type": "application/json"},
    body: jsonBody,
  );

  // 서버 응답 처리
  if (httpResponse.statusCode == 200) {
    print('Response from the server: ${httpResponse.body}');
  } else {
    print('Failed to send data. Status code: ${httpResponse.statusCode}');
  }
}

}

  // 사용자 메시지와 봇 응답을 서버로 전송하는 내부 함수
  Future<void> _sendChatMessageToServer(
      String? userMessage, String botResponse) async {
    final body = json.encode({
      'userMessage': userMessage,
      'botResponse': botResponse,
    });

    await http.post(
      Uri.parse('$_backendUrl/chat-messages'),
      headers: {"Content-Type": "application/json "},
      body: body,
    );
  }

  // 추가 기능 구현 부분 (생략)
  // 예를 들어, 채팅 메시지를 지우거나 데이터베이스에서 메시지를 가져오는 기능 등
}
