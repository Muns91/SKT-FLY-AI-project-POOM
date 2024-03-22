import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/chat/chat_screen.dart';
import 'package:shop_app/screens/voicemail/voicemail_screen.dart';
import 'package:shop_app/screens/favorite/favorite_screen.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:shop_app/screens/voicerecord/voicerecord_screen.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

// 녹음 상태를 나타내는 enum을 클래스 외부에 정의합니다.
enum RecordingState { notStarted, recording, completed }

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  static String routeName = "/";

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;

  final pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const VoiceRecordScreen(),
    const ChatScreen(),
    const VoicemailScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 2) {
            showDialog(
              context: context,
              builder: (BuildContext context) => RecordingDialog(),
            );
          } else {
            setState(() {
              currentSelectedIndex = index;
            });
          }
        },
        currentIndex: currentSelectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Shop Icon.svg",
              color: inActiveIconColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/Shop Icon.svg",
              color: kPrimaryColor,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Heart Icon.svg",
              color: inActiveIconColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/Heart Icon.svg",
              color: kPrimaryColor,
            ),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Call.svg",
              color: inActiveIconColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/Call.svg",
              color: kPrimaryColor,
            ),
            label: "Call",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Chat bubble Icon.svg",
              color: inActiveIconColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/Chat bubble Icon.svg",
              color: kPrimaryColor,
            ),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Mail.svg",
              color: inActiveIconColor,
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/Mail.svg",
              color: kPrimaryColor,
            ),
            label: "Voicemail",
          ),
        ],
      ),
    );
  }
}

class RecordingDialog extends StatefulWidget {
  @override
  _RecordingDialogState createState() => _RecordingDialogState();
}

class _RecordingDialogState extends State<RecordingDialog> {
  RecordingState recordingState = RecordingState.notStarted;

  void _handleStartRecording() {
    print(1);
    // 녹음 시작 시 실행될 함수
    // 아직 구현할 내용이 없으므로 아무 동작도 수행하지 않음
  }

  void _handleCompleteRecording() {
    print(2);
    // 녹음 완료 시 실행될 함수
    // 아직 구현할 내용이 없으므로 아무 동작도 수행하지 않음
  }

  String getImagePath(RecordingState state) {
    switch (state) {
      case RecordingState.notStarted:
        return "assets/images/recordstart.png"; // 녹음 시작 전 이미지, 실제 경로로 대체 필요
      case RecordingState.recording:
        return "assets/images/recording.gif"; // 녹음 중 이미지, 실제 경로로 대체 필요
      case RecordingState.completed:
        return "assets/images/recordfin.gif"; // 녹음 완료 이미지, 실제 경로로 대체 필요
      default:
        return "assets/images/recordstart.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = getImagePath(recordingState);

    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: 200,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  switch (recordingState) {
                    case RecordingState.notStarted:
                      recordingState = RecordingState.recording;
                      _handleStartRecording(); // 녹음 시작 함수 호출
                      break;
                    case RecordingState.recording:
                      recordingState = RecordingState.completed;
                      _handleCompleteRecording(); // 녹음 완료 함수 호출
                      break;
                    case RecordingState.completed:
                      Navigator.of(context).pop(); // 팝업 닫기
                      break;
                  }
                });
              },
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            Text(
              recordingState == RecordingState.notStarted
                  ? "녹음 시작"
                  : recordingState == RecordingState.recording
                  ? "녹음 진행"
                  : "녹음 완료",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
