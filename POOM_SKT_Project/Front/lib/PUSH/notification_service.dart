import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
 
class NotificationService {
  // 싱글톤 패턴을 사용하기 위한 private static 변수
  static final NotificationService _instance = NotificationService._();
  // NotificationService 인스턴스 반환
  factory NotificationService() {
    return _instance;
  }
  // private 생성자
  NotificationService._();
  // 로컬 푸시 알림을 사용하기 위한 플러그인 인스턴스 생성
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // 초기화 작업을 위한 메서드 정의
  Future<void> init() async {
    // 알림을 표시할 때 사용할 로고를 지정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // 안드로이드 플랫폼에서 사용할 초기화 설정
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    // 로컬 푸시 알림을 초기화
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  // 푸시 알림 생성
Future<void> showNotification(int id, String title, String body) async {
  const int notificationId = 0; // 알림 ID는 필요에 따라 조정 가능
  final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'channel_id', // 알림 채널 ID
    'Channel Name', // 알림 채널 이름
    channelDescription: 'Channel Description', // 알림 채널 설명
    importance: Importance.high, // 알림 중요도
  );
  final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
    notificationId, // 알림 ID
    title, // 동적 알림 제목
    body, // 동적 알림 메시지
    notificationDetails, // 알림 상세 정보
  );
}
  // 푸시 알림 권한 요청
  Future<PermissionStatus> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status;
  }
}