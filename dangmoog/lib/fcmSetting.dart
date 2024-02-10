// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:dangmoog/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// FlutterLocalNotificationsPlugin 전역 인스턴스
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Android 알림 채널 생성
const AndroidNotificationChannel channelSetting = AndroidNotificationChannel(
  'dotorit_chat_channel', // 채널 ID
  'dotorit_chat_channel', // 채널 이름
  description: 'This channel is used for dotorit chat notifications.', // 채널 설명
  importance: Importance.high,
);
// Android 및 iOS 알림 세부 정보
const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'dotorit_chat_channel', // 채널 ID
  'dotorit_chat_channel', // 채널 이름
  channelDescription:
      'This channel is used for dotorit chat notifications.', // 채널 설명
  importance: Importance.high,
  priority: Priority.high,
);

// 알림 채널 설정 함수
Future<void> setupNotifications() async {
  // Android 초기화 설정
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS 초기화 설정 추가
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channelSetting);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String title = message.notification?.title ?? "알림";
  String messageText = "message";

  Map<String, dynamic> data = message.data;
  String? bodyJson = data['body'];
  if (bodyJson != null) {
    Map<String, dynamic> body = jsonDecode(bodyJson);
    String type = body['type'];
    messageText = type == "img" ? "사진" : body['message'];
  }

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(
      presentAlert: true, // 알림 메시지 표시
      presentBadge: true, // 앱 아이콘에 배지 표시
      presentSound: true, // 알림 사운드 재생
    ),
  );

  // 알림 표시
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    messageText,
    platformChannelSpecifics,
  );
}

Future<String?> fcmSetting() async {
  // firebase core 기능 사용을 위한 필수 initializing
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // foreground 에서의 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channelSetting);

  // foreground 푸시 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("foregorund mesga");
    print(message.toString());

    // RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    String title = message.notification?.title ?? "알림";
    String messageText = "message";
    print(title);

    Map<String, dynamic> data = message.data;
    String? bodyJson = data['body'];
    if (bodyJson != null) {
      Map<String, dynamic> body = jsonDecode(bodyJson);
      String type = body['type'];
      messageText = type == "img" ? "사진" : body['message'];
    }

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true, // 알림 메시지 표시
        presentBadge: true, // 앱 아이콘에 배지 표시
        presentSound: true, // 알림 사운드 재생
      ),
    );

    print("메시지");
    print(messageText);

    if (message.notification != null && android != null) {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        // messageText,
        "포그라운드여",
        platformChannelSpecifics,
      );
    }
  });

  await messaging
      .getInitialMessage()
      .then((message) => _firebaseMessagingBackgroundHandler);

  // firebase token 발급
  String? firebaseToken = await messaging.getToken();
  return firebaseToken;
}
