// import 'package:flutter/material.dart';
// import 'package:shop_app/screens/home/home_screen.dart';

// class SharedCalenderScreen extends StatelessWidget {
//   static String routeName = "/shared_calendar";

//   const SharedCalenderScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: InkWell(
//           onTap: () {
//             // 로고 클릭 시 HomeScreen으로 이동
//             Navigator.pushNamed(context, HomeScreen.routeName);
//           },
//           child: SizedBox(
//             width: 125,
//             height: 70,
//             child: Image.asset('assets/images/poom_app_logo.png', fit: BoxFit.contain),
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: Center(
//               child: Text(
//                 "Shared Calendar",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ],
//         elevation: 0,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(2.0),
//           child: Container(
//             height: 2.0,
//             decoration: BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFF81D4FA),
//                   spreadRadius: 0,
//                   blurRadius: 2,
//                   offset: Offset(0, 1),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Center(
//         child: Text("Welcome to Shared Calendar Screen!"),
//       ),
//     );
//   }
// }
