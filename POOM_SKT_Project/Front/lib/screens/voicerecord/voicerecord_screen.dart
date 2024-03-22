import 'package:flutter/material.dart';

class VoiceRecordScreen extends StatelessWidget {
  static String routeName = "/voicerecord"; // 라우트 이름을 "/voicerecord"로 설정

  const VoiceRecordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voice Record"), // AppBar의 타이틀을 "Voice Record"로 설정
        elevation: 0, // AppBar의 기본 그림자를 제거합니다.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0), // 그림자의 "두께"를 얇게 조정
          child: Container(
            height: 2.0, // 실제 선 대신 그림자 높이
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF81D4FA), // 그림자 색상을 파란색 계열로 설정
                  spreadRadius: 0, // 그림자가 퍼지는 범위를 최소화
                  blurRadius: 2, // 그림자의 흐림 효과를 줄여 더 짙게 보이게 함
                  offset: Offset(0, 1), // 그림자의 방향 및 거리 설정
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text("Welcome to Voice Record Screen!"), // 화면에 표시되는 텍스트 수정
      ),
    );
  }
}
