import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'components/discount_banner.dart';
import 'components/popular_product.dart';
import 'components/special_offers.dart';
import 'home_screen.dart';
import 'package:shop_app/screens/profile/profile_screen.dart';


class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 125, // 로고 이미지의 크기를 조절합니다.
          height: 70, // 로고 이미지의 크기를 조절합니다.
          child: Image.asset('assets/images/poom_app_logo.png', fit: BoxFit.contain),
        ),
        centerTitle: true, // 로고 이미지를 가운데 정렬합니다.
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
            icon: SizedBox(
              width: 60,
              height: 24,
              child: SvgPicture.asset('assets/icons/User Icon.svg'),
            ),
          ),
        ],
        elevation: 0, // AppBar의 기본 그림자를 제거합니다.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0), // 그림자의 "두께"를 얇게 조절
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: const [
              DiscountBanner(),
              SpecialOffers(),
              SizedBox(height: 20),
              PopularProducts(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
