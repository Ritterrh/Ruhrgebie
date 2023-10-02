import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:package_info_plus/package_info_plus.dart";
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _latestVersion = '';

  @override
  void initState() {
    super.initState();
    _checkVersion();

    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    final response = await http.get(Uri.parse('https://example.com/version'));
    final data = json.decode(response.body);
    setState(() {
      _latestVersion = data['version'];
    });
  }

  final Uri _url = Uri.parse('https://github.com/Ritterrh/Ruhrgebie/releases');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Check for updates'),
          onPressed: () async {
            final packageInfo = await PackageInfo.fromPlatform();
            final currentVersion = packageInfo.version;

            if (currentVersion != _latestVersion) {
              // Show a dialog to inform the user that a new version is available
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('New version available'),
                    content: const Linkify(
                      text: 'Please update the app. download link here',
                      style: TextStyle(color: Colors.blue),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Update'),
                        onPressed: () {
                          _launchUrl();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'You are running the latest version of the app.',
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
