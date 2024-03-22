import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);

  final String title;
  final VoidCallback press; // GestureTapCallback 대신 VoidCallback 사용

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: press, // 수정된 부분: press 콜백 직접 사용
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text("더보기"),
        ),
      ],
    );
  }
}
