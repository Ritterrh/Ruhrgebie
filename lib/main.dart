import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:RuhurKulturErlbnisApp/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'music_channel',
        channelName: 'Ruhurkulturerlebnis Musik',
        channelDescription: 'All notifications related to your music',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        playSound: true,
        enableLights: true,
        enableVibration: true,
      ),
    ],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: ScaffoldMessenger(child: HomePage()));
  }
}
