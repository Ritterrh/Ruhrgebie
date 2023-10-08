import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:upgrade/upgrade.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingPage> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    UpgradeManager.instance.init(
      url: "http://localhost:8000/appcast/latest",
      currentVersionPath: "assets/version/version.json",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Allgemein',
            tiles: [
              SettingsTile(
                title: 'Update prüfen',
                onTap: () async {
                  print("Update prüfen Button gedrückt");
                  UpgradeManager.instance.checkForUpdates();
                  UpgradeStatus status = UpgradeManager.instance.status;

                  if (status == UpgradeStatus.available) {
                    // Zeige den Upgrade-Dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Update verfügbar'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  'Ein Update ist verfügbar. Möchten Sie es installieren?'),
                              LinearProgressIndicator(
                                value: progress,
                              ),
                            ],
                          ),
                          actions: [
                            GestureDetector(
                              onTap: () async {
                                // Starte den Download
                                UpgradeManager.instance.download(
                                  onReceiveProgress: (received, total, _) {
                                    setState(() {
                                      progress = received / total;
                                    });
                                  },
                                  onDone: () {
                                    // Installiere das Update
                                    UpgradeManager.instance.install();
                                    Navigator.of(context)
                                        .pop(); // Schließe den Dialog
                                  },
                                );
                              },
                              child: const Text('Installieren'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Schließe den Dialog
                              },
                              child: const Text('Abbrechen'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
