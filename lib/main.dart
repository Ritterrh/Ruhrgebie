import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:RuhurKulturErlbnisApp/pages/home.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:background_fetch/background_fetch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'music_channel',
        channelName: 'Ruhurkulturerlebnis Musik',
        channelDescription:
            'Alle Benachrichtigungen im Zusammenhang mit Ihrer Musik',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        playSound: true,
        enableLights: true,
        enableVibration: true,
      ),
    ],
  );

  // Lese die aktuelle App-Version aus den Package-Informationen
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  runApp(MyApp(currentVersion: currentVersion));

  // Hintergrund-Aktualisierung einrichten
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval:
          15, // Intervall in Minuten, wie oft die Funktion ausgeführt wird
      stopOnTerminate:
          false, // Die Funktion wird auch nach dem Schließen der App ausgeführt
      enableHeadless: true,
      forceAlarmManager: false,
      requiredNetworkType: NetworkType.NONE,
    ),
    (String taskId) async {
      // Diese Funktion wird im Hintergrund ausgeführt
      checkForUpdates(currentVersion);
      BackgroundFetch.finish(taskId);
    },
  );
}

class MyApp extends StatelessWidget {
  final String currentVersion;

  const MyApp({Key? key, required this.currentVersion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: ScaffoldMessenger(child: HomePage()),
    );
  }
}

void checkForUpdates(String currentVersion) async {
  // Hier implementierst du die Logik zum Überprüfen von Updates
  // Vergleiche die aktuelle Version mit der neuesten Version
  final latestVersion =
      await getLatestVersion(); // Hier musst du die aktuelle Version vom Server abrufen

  if (currentVersion != latestVersion) {
    // Wenn eine neue Version verfügbar ist, zeige eine Benachrichtigung an
    showUpdateNotification();
  }
}

Future<String> getLatestVersion() async {
  // Hier kannst du eine HTTP-Anfrage durchführen, um die neueste Version von einem Server abzurufen
  // Beispiel: Eine GET-Anfrage an eine URL, die die neueste Version zurückgibt
  // Du solltest diese Logik entsprechend deinen Anforderungen implementieren
  final response =
      await http.get(Uri.parse('https://api.filmprojekt1.de/api/version'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final latestVersion = data['version'];
    return latestVersion;
  }
  return '';
}

void showUpdateNotification() {
  // Zeige eine Benachrichtigung über Awesome Notifications an
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'music_channel',
      title: 'Neue Version verfügbar',
      body:
          'Eine neue Version deiner App ist verfügbar. Bitte aktualisiere jetzt.',
    ),
  );
}
