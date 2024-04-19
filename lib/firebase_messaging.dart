import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService{
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static Future<void> initialize() async{
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data);
      print(message.notification?.title);
      print(message.notification?.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message.data);
      print(message.notification?.title);
      print(message.notification?.body);
    });
    FirebaseMessaging.onBackgroundMessage(doSomething);
    _listenToTokenRefresh();
  }

  static Future<String?> getFCMToken() async {
    return _firebaseMessaging.getToken();
  }

  static Future<void> _listenToTokenRefresh() async {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      //
    });
  }

}

Future<void> doSomething(RemoteMessage message) async{
  //
}