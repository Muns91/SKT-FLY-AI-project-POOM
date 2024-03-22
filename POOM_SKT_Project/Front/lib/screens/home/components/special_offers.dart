import 'package:flutter/material.dart';
import 'package:shop_app/screens/products/products_screen.dart';

import 'section_title.dart';
import 'package:shop_app/screens/sharedcalender_screen/sharedcalender_screen.dart'; // SharedCalenderScreen import 추가

class SpecialOffers extends StatelessWidget {
  const SpecialOffers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Shared Calender",
            press: () {
              // 더보기 버튼을 누를 때 SharedCalenderScreen으로 이동
              Navigator.pushNamed(context, SharedCalenderScreen.routeName);
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SpecialOfferCard(
                image: "assets/images/Image Banner 2.png",
                category: "오늘 할 일\n치과 진료 가기",
                press: () {
                  // 기존 버튼과 동일하게 ProductsScreen으로 이동하도록 설정
                  Navigator.pushNamed(context, SharedCalenderScreen.routeName);
                },
              ),
              const SizedBox(width: 20),
              SpecialOfferCard(
                image: "assets/images/Image Banner 3.png",
                category: "내일 할 일\n한의원 진료 예약",
                press: () {
                  // 기존 버튼과 동일하게 ProductsScreen으로 이동하도록 설정
                  Navigator.pushNamed(context, SharedCalenderScreen.routeName);
                },
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    Key? key,
    required this.category,
    required this.image,
    required this.press,
  }) : super(key: key);

  final String category, image;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: press,
        child: SizedBox(
          width: 242,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.black38,
                        Colors.black26,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "$category",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
