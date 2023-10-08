import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:RuhurKulturErlbnisApp/widget/appbar.dart';
import 'package:provider/provider.dart';
import 'package:RuhurKulturErlbnisApp/model/AudioData.dart';

class AudioGuid extends StatefulWidget {
  const AudioGuid({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AudioGuidState createState() => _AudioGuidState();
}

class _AudioGuidState extends State<AudioGuid> {
  final _audioPlayer = AssetsAudioPlayer();
  Duration _duration = const Duration();
  late String errotext = "";
  late String errotitel = "";
  bool _loadingAudioData = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _requestPermissions1();
        _requestPermissions();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _requestPermissions1();
    await _requestPermissions();

    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _requestPermissions1();
        _requestPermissions();
      }
    });
  }

  Future<void> _requestPermissions1() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(errotitel),
              Text(
                'AudioGuid 84 $errotext',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(errotitel),
              Text(
                'AudioGuid 103 $errotext',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _fetchAudioData() async {
    if (Provider.of<AudioData>(context, listen: false).isPlaying == false) {
      setState(() {
        _loadingAudioData = true;
      });
      await _requestPermissions1();
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      final latitude = position.latitude;
      final longitude = position.longitude;

      print('Fetching audio data...');
      final response = await http.get(
          Uri.parse(
              'https://api.filmprojekt1.de/api/audio?userLatitude=$latitude&userLongitude=$longitude'),
          headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        print('Audio data fetched successfully!');
        final responseData = json.decode(response.body);

        if (responseData != null) {
          print("Response Data: $responseData");
          final audioFiles = responseData['audioFiles'];

          if (audioFiles is List<dynamic> && audioFiles.isNotEmpty) {
            final audioData = audioFiles[0];

            final audioDataProvider =
                // ignore: use_build_context_synchronously
                Provider.of<AudioData>(context, listen: false);

            audioDataProvider.setTitel(audioData['title']);
            audioDataProvider.setDescription(audioData['description']);
            audioDataProvider.setImageUrl(audioData['img_url']);
            audioDataProvider.setCreator(audioData['creator']);
            audioDataProvider.setAudioUrl(audioData['audio_url']);

            // AudioInfo erstellen und zur Liste hinzufügen

            setState(() {
              _loadingAudioData = false;
            });
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Text("Audio Geladen"),
                    Text(
                      "Audio wurde erfolgreich in audio info geladen",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text(errotitel),
                    Text(
                      'Keine Audio für diesen Standort verfügbar $errotext',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(errotitel),
                  Text(
                    'AudioGuid 171 $errotext',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(errotitel),
                Text(
                  "AudioGuid  187 $errotext",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  double _calculateMaxDuration() {
    if (_audioPlayer.current.value != null) {
      final currentAudio = _audioPlayer.current.value!;
      final maxDuration = currentAudio.audio.duration;
      setState(() {
        _duration = maxDuration;
      });
      return maxDuration.inSeconds.toDouble();
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final audioData = Provider.of<AudioData>(context, listen: true);
    return Stack(
      children: [
        Hero(
          tag: "image",
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(audioData.imageUrl ??
                        "https://image.jimcdn.com/app/cms/image/transf/dimension=1920x10000:format=jpg/path/sfe162db7f5417cfe/image/if0d5387e710379d2/version/1515333113/image.jpg"),
                    fit: BoxFit.cover)),
          ),
        ),
        _loadingAudioData
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    CircularProgressIndicator(),
                  ])
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        blurRadius: 14,
                        spreadRadius: 16,
                        color: Colors.black.withOpacity(0.2),
                      )
                    ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  width: 1.5,
                                  color: Colors.white.withOpacity(0.2))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      audioData.titel,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  audioData.creator,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  audioData.description,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              Column(
                                children: [
                                  Slider(
                                    value: _audioPlayer
                                        .currentPosition.value.inSeconds
                                        .toDouble(),
                                    min: 0.0,
                                    max: _duration.inSeconds.toDouble(),
                                    onChanged: (double value) {
                                      setState(() {
                                        _audioPlayer.seek(
                                            Duration(seconds: value.toInt()));
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Duration(
                                                  seconds: _audioPlayer
                                                      .currentPosition
                                                      .value
                                                      .inSeconds)
                                              .toString()
                                              .split('.')[0]
                                              .substring(2),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.skip_previous_outlined),
                                          color: Colors.white,
                                          iconSize: 40,
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: _audioPlayer.isPlaying.value ==
                                                  true
                                              ? const Icon(Icons.pause,
                                                  color: Colors.white, size: 50)
                                              : const Icon(Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 50),
                                          onPressed: () async {
                                            _audioPlayer.pause();
                                            if (Provider.of<AudioData>(context,
                                                        listen: false)
                                                    .isPlaying ==
                                                false) {
                                              final audioUrl =
                                                  Provider.of<AudioData>(
                                                          context,
                                                          listen: false)
                                                      .audioUrl;
                                              await _audioPlayer.open(
                                                Audio.network(audioUrl,
                                                    metas: Metas(
                                                      title: Provider.of<
                                                                  AudioData>(
                                                              context,
                                                              listen: false)
                                                          .titel,
                                                      artist: Provider.of<
                                                                  AudioData>(
                                                              context,
                                                              listen: false)
                                                          .description,
                                                      image: MetasImage.network(
                                                          Provider.of<AudioData>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .imageUrl ??
                                                              "https://image.jimcdn.com/app/cms/image/transf/dimension=1920x10000:format=jpg/path/sfe162db7f5417cfe/image/if0d5387e710379d2/version/1515333113/image.jpg"),
                                                    )),
                                                showNotification: true,
                                                notificationSettings:
                                                    const NotificationSettings(
                                                  stopEnabled: true,
                                                  playPauseEnabled: true,
                                                  nextEnabled: false,
                                                  prevEnabled: false,
                                                  seekBarEnabled: true,
                                                ),
                                                playInBackground: PlayInBackground
                                                    .enabled, // Erlaube Hintergrundwiedergabe
                                              );
                                              _audioPlayer.currentPosition
                                                  .listen(
                                                (position) {
                                                  _audioPlayer.current
                                                      .listen((event) {
                                                    if (mounted) {
                                                      setState(() {
                                                        _calculateMaxDuration();
                                                        Provider.of<AudioData>(
                                                                context,
                                                                listen: false)
                                                            .setIsPlaying(true);
                                                      });
                                                    }
                                                  });
                                                  _audioPlayer.current
                                                      .listen((onDone) {
                                                    if (mounted) {
                                                      setState(() {
                                                        _calculateMaxDuration();
                                                        Provider.of<AudioData>(
                                                                context,
                                                                listen: false)
                                                            .setIsPlaying(
                                                                false);
                                                      });
                                                    }
                                                  });
                                                },
                                              );
                                            } else {
                                              _audioPlayer.play();
                                              if (mounted) {
                                                _audioPlayer.stop();
                                              }
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.skip_next_outlined),
                                          color: Colors.white,
                                          iconSize: 40,
                                          onPressed: () {
                                            // Implementieren Sie die Logik für das nächste Audio
                                          },
                                        ),
                                        Text(
                                          Duration(seconds: _duration.inSeconds)
                                              .toString()
                                              .split('.')[0]
                                              .substring(2),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.5),
                                              disabledForegroundColor:
                                                  Colors.grey.withOpacity(0.38),
                                            ),
                                            onPressed: () {
                                              audioData.setIsPlaying(false);
                                              _fetchAudioData();
                                            },
                                            child: const Text(
                                                "Audio Daten Neu laden ")),
                                        const Text(
                                          "Audio Daten\n nur neue laden\n wenn das\n audio fertig ist da\n es sonst doopelt läuft",
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
