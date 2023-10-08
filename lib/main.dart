import 'package:RuhurKulturErlbnisApp/firebase_options.dart';
import 'package:RuhurKulturErlbnisApp/pages/auth.dart';
import 'package:get/get.dart';
import 'package:material3_layout/material3_layout.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:RuhurKulturErlbnisApp/model/AudioData.dart';

import 'package:RuhurKulturErlbnisApp/pages/settings.dart';
import 'package:RuhurKulturErlbnisApp/pages/audioguid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("firebase initialized");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioData>(
          create: (_) => AudioData(),
        ),
        // Weitere Provider können hier hinzugefügt werden, falls erforderlich.
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const SettingPage();
            } else {
              return const AuthGate();
            }
          },
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('RuhrKultur ErlebnisApp '),
        centerTitle: true,
      ),
      theme: Theme.of(context),
      navigationType: NavigationTypeEnum.railAndBottomNavBar,
      navigationSettings: RailAndBottomSettings(
        destinations: <DestinationModel>[
          DestinationModel(
            label: 'Profile',
            icon: const Icon(Icons.person_2_outlined),
            selectedIcon: const Icon(Icons.person_2),
            tooltip: 'Profile page',
          ),
          DestinationModel(
            label: 'Settings',
            badge: Badge.count(
              count: 3,
              child: const Icon(Icons.settings_outlined),
            ),
            selectedIcon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
        pages: <Widget>[
          const AudioGuid(),
          const SettingPage(),
        ],
        addThemeSwitcherTrailingIcon: true,
        groupAlignment: 0.0,
      ),
      onDestinationSelected: (int index) => log(
        'Page changed: Current page: $index',
      ),
    );
  }
}
