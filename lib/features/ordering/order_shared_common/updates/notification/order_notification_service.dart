// lib/features/order_shared_common/provider/order_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OrderNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  OrderNotificationService(this._notificationsPlugin) {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showOrderConfirmationNotification({
    required String orderId,
    required String restaurantName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_confirmation_channel',
      'Order Confirmations',
      channelDescription: 'Notifications for order_shared_common confirmations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Order Confirmed!',
      'Your order_shared_common #$orderId from $restaurantName has been confirmed',
      details,
    );
  }

  Future<void> showOrderStatusUpdateNotification({
    required String orderId,
    required String status,
    required String restaurantName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_status_channel',
      'Order Status Updates',
      channelDescription: 'Notifications for order_shared_common status updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1,
      'Order Status Update',
      'Your order_shared_common #$orderId from $restaurantName is now $status',
      details,
    );
  }
}
