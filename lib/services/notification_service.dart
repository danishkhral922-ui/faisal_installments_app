class NotificationService {
  static Future<void> initialize() async {}

  static Future<bool> requestPermission() async => true;

  static Future<void> showReminderNotification({
    required String title,
    required String body,
  }) async {}
}
