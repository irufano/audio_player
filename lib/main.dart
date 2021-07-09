import 'package:audio_player/page/list_media_item_page.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'locator/locator.dart';
import 'service/audio_player_service.dart';

// audio handler using dependency injection
var _audioPlayerService = locator<AudioPlayerService>();

void main() async {
  await setupLocator();
  await _audioPlayerService.setup();

  AudioService.notificationClicked.listen((event) {
    print('--- Cliked ---');
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Background Player'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => ListMediaItemPage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
