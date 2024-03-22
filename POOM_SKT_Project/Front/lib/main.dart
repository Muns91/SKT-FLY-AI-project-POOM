import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PUSH/notification_service.dart';
import 'package:shop_app/screens/splash/splash_screen.dart';
import 'routes.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // 알림 서비스 초기화
  runApp(MyApp());
  startPolling(); // 데이터 폴링 시작
}

String lastWishlistResponse = ""; // 마지막으로 받은 '/wishlist' 응답
String lastMessageResponse = ""; // 마지막으로 받은 '/receive-message' 응답

void startPolling() {
  Timer.periodic(Duration(seconds: 5), (Timer t) async {
    // '/wishlist'에서 데이터 확인
    try {
      var wishlistResponse = await http.get(Uri.parse('http://URL:3001/wishlist'));
      print("Received wishlist response: ${wishlistResponse.body}");
      if (wishlistResponse.statusCode == 200 && wishlistResponse.body.isNotEmpty && wishlistResponse.body != lastWishlistResponse) {
        
        var title = "POOM";
        var body = "위시리스트에 상품이 등록되었습니다.";
        NotificationService().showNotification(1, title, body);
        lastWishlistResponse = wishlistResponse.body;
      }
    } catch (e) {
      print("'/wishlist' 폴링 중 에러 발생: $e");
    }

    // '/receive-message'에서 데이터 확인
    try {
      var messageResponse = await http.get(Uri.parse('http://URL:3001/receive-message'));
      print("Received message response: ${messageResponse.body}");
      if (messageResponse.statusCode == 200 && messageResponse.body.isNotEmpty && messageResponse.body != lastMessageResponse) {
        
        var jsonData = jsonDecode(messageResponse.body);
        print(jsonData);
        String body = "새로운 메시지가 도착했습니다."; // 기본 메시지

        if (jsonData.isNotEmpty) {
          var messageData = jsonDecode(jsonData[0]['message']);
          
          if (messageData.containsKey('greeting message')) {
            body = messageData['greeting message'];
          } else if (messageData.containsKey('shared calendar event')) {
            body = messageData['shared calendar event'][1]; // 두 번째 요소가 이벤트 설명
          }
        }

        var title = "POOM";
        NotificationService().showNotification(2, title, body);
        lastMessageResponse = messageResponse.body;
      }
    } catch (e) {
      print("'/receive-message' 폴링 중 에러 발생: $e");
    }
  });
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Flutter Way - Template',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
