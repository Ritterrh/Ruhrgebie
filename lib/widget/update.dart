import 'package:flutter/material.dart';
import 'package:upgrade/upgrade.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingPage> {
  late bool updatet = false;

  @override
  void initState() {
    super.initState();
    UpgradeManager.instance.init(
        url: "https://api.filmprojekt1.de/api/appcast/latest",
        currentVersionPath: ('assets/version/version.json'));
  }

  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RuhrKulturErlebnis-App',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Filmprojekt1',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Andere Widgets hier
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10),
                        ),
                        onPressed: () =>
                            UpgradeManager.instance.checkForUpdates(),
                        child: Text(
                          'Update suchen',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16), // Abstand zwischen den Buttons
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10),
                        ),
                        onPressed: () => UpgradeManager.instance.download(
                          onReceiveProgress: (received, total, _) {
                            setState(() {
                              progress = received / total;
                            });
                          },
                        ),
                        child: Text(
                          'Update herunterladen',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16), // Abstand zwischen den Buttons
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.all(10),
                        ),
                        onPressed: () => UpgradeManager.instance.install(),
                        child: Text(
                          'Update installieren',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildAppcastItemInfo({required String title, AppcastItem? item}) {
  if (item == null) {
    return Text("$title: null",
        style: const TextStyle(fontWeight: FontWeight.bold));
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
      Text("releaseNotes: ${item.releaseNotes}"),
      Text("version: ${item.version.toString()}"),
      Text("displayVersionString: ${item.displayVersionString}"),
      Text("os: ${item.os}"),
      Text("minimumSystemVersion: ${item.minimumSystemVersion}"),
      Text("maximumSystemVersion: ${item.maximumSystemVersion}"),
    ],
  );
}
