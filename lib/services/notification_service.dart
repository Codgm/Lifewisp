// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    // 타임존 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// 알림 클릭 시 처리
  void _onNotificationTap(NotificationResponse notificationResponse) {
    // 알림을 클릭했을 때의 동작을 여기에 구현
    print('Notification tapped: ${notificationResponse.payload}');

    // 만약 메인 앱으로 이동하고 싶다면:
    if (NavigationService.navigatorKey.currentContext != null) {
      // 홈 화면이나 일기 작성 화면으로 이동
      Navigator.of(NavigationService.navigatorKey.currentContext!)
          .pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  /// 알림 권한 요청 - 플랫폼별로 구분
  Future<bool> requestPermissions() async {
    try {
      // Android 13 이상에서는 POST_NOTIFICATIONS 권한 필요
      if (Theme.of(NavigationService.navigatorKey.currentContext!).platform ==
          TargetPlatform.android) {
        // Android 버전 확인
        final status = await Permission.notification.request();
        return status == PermissionStatus.granted;
      } else {
        // iOS 권한 요청
        final bool? result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result ?? false;
      }
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  /// 권한 상태 확인
  Future<bool> hasPermissions() async {
    try {
      if (Theme.of(NavigationService.navigatorKey.currentContext!).platform ==
          TargetPlatform.android) {
        // Android 권한 확인
        final status = await Permission.notification.status;
        return status == PermissionStatus.granted;
      } else {
        // iOS에서는 알림 스케줄링을 시도해보고 성공 여부로 판단
        // 또는 단순히 true를 반환 (iOS에서는 초기화 시점에 권한을 요청했으므로)
        return true; // iOS는 초기화 시점에 권한 요청을 했으므로 허용된 것으로 간주
      }
    } catch (e) {
      print('Permission check error: $e');
      return false;
    }
  }

  /// 일회성 알림 스케줄
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool enableSound = true,
    bool enableVibration = true,
    String? payload,
  }) async {
    await initialize();

    // 권한 체크
    if (!await hasPermissions()) {
      throw Exception('알림 권한이 필요합니다.');
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: '매일 감정 기록 알림',
      importance: Importance.high,
      priority: Priority.high,
      playSound: enableSound,
      enableVibration: enableVibration,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// 반복 알림 스케줄 (매일) - 수정된 버전
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    bool enableSound = true,
    bool enableVibration = true,
    String? payload,
  }) async {
    await initialize();

    // 권한 체크
    if (!await hasPermissions()) {
      throw Exception('알림 권한이 필요합니다.');
    }

    // 기존 알림이 있다면 먼저 취소
    await cancelNotification(id);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: '매일 감정 기록 알림',
      importance: Importance.high,
      priority: Priority.high,
      playSound: enableSound,
      enableVibration: enableVibration,
      icon: '@mipmap/ic_launcher',
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // 오늘 기준으로 알림 시간 계산
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 만약 오늘의 알림 시간이 이미 지났으면 내일로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('Scheduling notification for: $scheduledDate');

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
        payload: payload,
      );
      print('Daily notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
      throw Exception('알림 설정에 실패했습니다: $e');
    }
  }

  /// 알림 취소
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('Notification $id cancelled');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  /// 예약된 알림 목록 가져오기
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// 즉시 알림 표시
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool enableSound = true,
    bool enableVibration = true,
    String? payload,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'instant_notification_channel',
      'Instant Notifications',
      channelDescription: '즉시 알림',
      importance: Importance.high,
      priority: Priority.high,
      playSound: enableSound,
      enableVibration: enableVibration,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

/// 네비게이션 서비스 (GlobalKey를 위한 헬퍼 클래스)
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}