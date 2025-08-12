// lib/utils/notification_debug_helper.dart
// 개발 중 알림 상태를 확인하기 위한 디버깅 도구

import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationDebugHelper {
  static final NotificationService _notificationService = NotificationService();

  /// 현재 예약된 알림들을 확인
  static Future<void> printPendingNotifications() async {
    try {
      final pendingNotifications = await _notificationService.getPendingNotifications();
      print('=== 예약된 알림 목록 ===');
      print('총 ${pendingNotifications.length}개의 알림이 예약됨');

      for (final notification in pendingNotifications) {
        print('ID: ${notification.id}');
        print('제목: ${notification.title}');
        print('내용: ${notification.body}');
        print('페이로드: ${notification.payload}');
        print('---');
      }
      print('====================');
    } catch (e) {
      print('알림 목록 확인 중 오류: $e');
    }
  }

  /// 권한 상태 확인
  static Future<void> checkPermissionStatus() async {
    try {
      final hasPermission = await _notificationService.hasPermissions();
      print('=== 알림 권한 상태 ===');
      print('권한 허용됨: $hasPermission');
      print('==================');
    } catch (e) {
      print('권한 상태 확인 중 오류: $e');
    }
  }

  /// 모든 알림 취소 (디버그용)
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      print('모든 알림이 취소되었습니다.');
    } catch (e) {
      print('알림 취소 중 오류: $e');
    }
  }

  /// 즉시 테스트 알림 전송
  static Future<void> sendImmediateTestNotification() async {
    try {
      await _notificationService.showNotification(
        id: 99999,
        title: '🔧 디버그 테스트',
        body: '이것은 디버깅용 테스트 알림입니다.',
        payload: 'debug_test',
      );
      print('디버그 테스트 알림을 전송했습니다.');
    } catch (e) {
      print('테스트 알림 전송 중 오류: $e');
    }
  }

  /// 5초 후 알림 전송 (스케줄 테스트)
  static Future<void> scheduleTestNotificationIn5Seconds() async {
    try {
      final scheduledTime = DateTime.now().add(Duration(seconds: 5));
      await _notificationService.scheduleNotification(
        id: 88888,
        title: '⏰ 5초 후 알림',
        body: '스케줄된 알림이 정상 작동합니다!',
        scheduledDate: scheduledTime,
        payload: 'scheduled_test',
      );
      print('5초 후 알림이 예약되었습니다: $scheduledTime');
    } catch (e) {
      print('스케줄 알림 설정 중 오류: $e');
    }
  }
}

/// 디버그 플로팅 버튼 (개발용)
/// 설정 화면에 임시로 추가하여 사용할 수 있습니다.
class DebugNotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '알림 디버깅 도구',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    NotificationDebugHelper.printPendingNotifications();
                    Navigator.pop(context);
                  },
                  child: Text('예약된 알림 확인'),
                ),
                ElevatedButton(
                  onPressed: () {
                    NotificationDebugHelper.checkPermissionStatus();
                    Navigator.pop(context);
                  },
                  child: Text('권한 상태 확인'),
                ),
                ElevatedButton(
                  onPressed: () {
                    NotificationDebugHelper.sendImmediateTestNotification();
                    Navigator.pop(context);
                  },
                  child: Text('즉시 테스트 알림'),
                ),
                ElevatedButton(
                  onPressed: () {
                    NotificationDebugHelper.scheduleTestNotificationIn5Seconds();
                    Navigator.pop(context);
                  },
                  child: Text('5초 후 알림'),
                ),
                ElevatedButton(
                  onPressed: () {
                    NotificationDebugHelper.cancelAllNotifications();
                    Navigator.pop(context);
                  },
                  child: Text('모든 알림 취소'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
      child: Icon(Icons.bug_report),
      backgroundColor: Colors.orange,
    );
  }
}