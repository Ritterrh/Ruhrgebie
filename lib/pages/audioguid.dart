import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:RuhurKulturErlbnisApp/pages/widget/app_bottom_navigation_bar.dart';
import 'package:RuhurKulturErlbnisApp/pages/home.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioGuid extends StatefulWidget {
  const AudioGuid({Key? key}) : super(key: key);

  @override
  _AudioGuidState createState() => _AudioGuidState();
}

class _AudioGuidState extends State<AudioGuid> {
  final _audioPlayer = AssetsAudioPlayer();
  List<dynamic> _data = [];
  bool _isPlaying = false;
  String _title = '';
  String _subtitle = '';
  String _imageUrl = '';
  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isLoading = true;
  late String titel;
  late String description;
  late String imageUrl;

  @override
  void initState() async {
    super.initState();
    await _requestPermissions1();
    await _requestPermissions();
    await _fetchData();

    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _requestPermissions1();
        _requestPermissions();
        _fetchData();
      }
    });

    // Initialisieren Sie die Awesome Notifications Library.
    AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'music_channel',
          channelName: 'Music Channel',
          channelDescription: 'Channel for Music Notifications',
          playSound: true,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
        ),
      ],
    );
  }

  Future<void> _requestPermissions1() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
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

  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
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

  Future<void> _fetchData() async {
    _requestPermissions1();
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    final latitude = position.latitude;
    final longitude = position.longitude;
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
        Uri.parse(
            'https://api.filmprojekt1.de/api/audio?userLatitude=$latitude&userLongitude=$longitude'),
        headers: {'Accept': 'application/json'});
    final baseUri =
        "https://api.filmprojekt1.de/api/audio?userLatitude=$latitude&userLongitude=$longitude";
    print(baseUri);
    print("1");
    if (response.statusCode == 200) {
      print("2");
      Map<String, dynamic> responseData = json.decode(response.body);
      print("3");
      // ignore: unnecessary_null_comparison
      if (responseData != null && responseData['audioFiles'] != null) {
        print("4");
        setState(() {
          _data = responseData['audioFiles'];
          _isLoading = false;
        });
        print("5");
      } else {
        print("6");
        // Body:
        // Center(
        //   child: Text("Keine Audio Guides in der Nähe"),
        // );
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

  Future<void> _playAudio(String audioUrl, int index) async {
    if (_data[index] == null) {
      print("8");
      print("null");
    }
    titel = _data[index]['title'];
    description = _data[index]['description'];
    imageUrl = _data[index]['img_url'];

    print("Audio URL $audioUrl");
    await _audioPlayer.open(
      Audio.network(audioUrl,
          metas: Metas(
            title: titel,
            artist: description,
            image: MetasImage.network(imageUrl),
          )),
      showNotification: true,
      notificationSettings: const NotificationSettings(
        stopEnabled: true,
        playPauseEnabled: true,
        nextEnabled: false,
        prevEnabled: false,
      ),
    );

    // Setzen Sie den Audioplayer-Timer, um die Position zu aktualisieren.
    _audioPlayer.currentPosition.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
    AwesomeNotifications().cancel(1);
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
    AwesomeNotifications().cancel(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audio Guide',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text("Lade Audio Guide",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ],
            )
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (BuildContext context, int index) {
                print("7");
                if (_data[index] == null) {
                  print("8");
                  print("null");
                  return const SizedBox.shrink();
                }
                final String title = _data[index]['title'] ??
                    "Zu diesen Ort gibt es keinen Audio Guide";
                final String description = _data[index]['description'];
                final String audioUrl = _data[index]['audio_url'];
                print(audioUrl);
                final String imageUrl = _data[index]['img_url'];
                final String creator = _data[index]['creator'];
                return Card(
                  child: Column(
                    children: <Widget>[
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                      ListTile(
                        title: Text(title),
                        subtitle: Text(creator),
                        trailing: IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {/* ... */},
                        ),
                      ),
                      Text(description),
                      if (_isPlaying)
                        Slider(
                          value: _position.inSeconds.toDouble(),
                          min: 0,
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (double value) {
                            setState(() {
                              _audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            });
                          },
                        ),
                      ButtonBar(
                        children: <Widget>[
                          if (_isPlaying)
                            IconButton(
                              icon: Icon(
                                Icons.pause,
                                size: 50,
                              ),
                              onPressed: () {
                                _pauseAudio();
                              },
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                _playAudio(audioUrl, index);
                                _audioPlayer.play();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
      ),
    );
  }
}
