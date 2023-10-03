import 'dart:async';
import 'dart:convert';
import 'package:RuhurKulturErlbnisApp/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:RuhurKulturErlbnisApp/pages/audioguid.dart';
import 'package:RuhurKulturErlbnisApp/widget/app_bottom_navigation_bar.dart';
import 'package:RuhurKulturErlbnisApp/widget/appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _data = [];
  late String errotext = "";
  late String errotitel = "";
  late Timer _timer;

  Future<void> _fetchData() async {
    final response =
        await http.get(Uri.parse('https://api.filmprojekt1.de/api/game'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          if (mounted) _data = json.decode(response.body);
        });
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(errotitel),
              Text(
                'Home 149 $errotext',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchData();
      } else {
        _timer
            .cancel(); // Stoppen Sie den Timer, wenn das Widget "ausgeschaltet" wurde.
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer
        .cancel(); // Stellen Sie sicher, dass der Timer im dispose() gestoppt wird.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //APPBAR ANFANG
      appBar: appbar(),
      //APPBAR ENDE

      //BODY ANFANG
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: <Widget>[
                Image.network(
                  _data[index]['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                ),
                ListTile(
                  title: Text(_data[index]['spiel_name']),
                  subtitle: Text(_data[index]['PB_name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {/* ... */},
                  ),
                ),
              ],
            ),
          );
        },
      ),
      //BODY ENDE

      //Bottom Navigation Bar Ananfang
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AudioGuid()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            );
          }
        },
        bg: Colors.white,
      ),
      //Bottom Navigation Bar Ende
    );
  }
}
