import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:RuhurKulturErlbnisApp/pages/audioguid.dart';
import 'package:RuhurKulturErlbnisApp/pages/widget/app_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _data = [];

  Future<void> _fetchData() async {
    final response =
        await http.get(Uri.parse('https://api.filmprojekt1.de/api/game'));
    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text('Failed to load data: '),
              Text(
                'Please check your internet connection and try again.',
                style: TextStyle(fontWeight: FontWeight.bold),
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
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //APPBAR ANFANG
      appBar: AppBar(
        title: const Text(
          'Ruhurkulturerlebnis',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
        },
      ),
      //Bottom Navigation Bar Ende
    );
  }
}
