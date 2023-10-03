import 'package:RuhurKulturErlbnisApp/pages/home.dart';
import 'package:RuhurKulturErlbnisApp/widget/update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:RuhurKulturErlbnisApp/model/AudioData.dart';

void main() {
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: HomePage(),
      ),
    );
  }
}
