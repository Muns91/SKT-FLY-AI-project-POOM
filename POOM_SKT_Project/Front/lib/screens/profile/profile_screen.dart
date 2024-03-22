import 'package:flutter/material.dart';
import 'package:shop_app/screens/home/home_screen.dart';

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            // 로고 클릭 시 HomeScreen으로 이동
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          child: SizedBox(
            width: 125,
            height: 70,
            child: Image.asset('assets/images/poom_app_logo.png', fit: BoxFit.contain),
          ),
        ),
        centerTitle: true, // 로고 이미지를 가운데 정렬합니다.
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "PROFILE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
        elevation: 0, // AppBar의 기본 그림자를 제거합니다.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0), // 그림자의 "두께"를 조절합니다.
          child: Container(
            height: 2.0, // 그림자 높이
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF81D4FA), // 그림자 색상을 파란색 계열로 설정합니다.
                  spreadRadius: 0, // 그림자가 퍼지는 범위를 최소화합니다.
                  blurRadius: 2, // 그림자의 흐림 효과를 줄여 더 짙게 보이게 합니다.
                  offset: Offset(0, 1), // 그림자의 방향 및 거리를 설정합니다.
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "나의 계정",
              icon: "assets/icons/User Icon.svg",
              press: () => {},
            ),
            ProfileMenu(
              text: "알림",
              icon: "assets/icons/Bell.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "설정",
              icon: "assets/icons/Settings.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "고객 센터",
              icon: "assets/icons/Question mark.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "로그아웃",
              icon: "assets/icons/Log out.svg",
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}
