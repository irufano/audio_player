import 'package:audio_player/locator/locator.dart';
import 'package:audio_player/service/audio_player_service.dart';
import 'package:flutter/material.dart';

// audio handler using dependency injection
var _audioPlayerService = locator<AudioPlayerService>();

Widget playButton(BuildContext context) => Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: _audioPlayerService.handler.play,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: MediaQuery.of(context).size.height / 12,
          width: MediaQuery.of(context).size.height / 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: MediaQuery.of(context).size.height / 18,
            color: Colors.white,
          ),
        ),
      ),
    );

Widget pauseButton(BuildContext context) => Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: _audioPlayerService.handler.pause,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: MediaQuery.of(context).size.height / 12,
          width: MediaQuery.of(context).size.height / 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.pause,
            size: MediaQuery.of(context).size.height / 18,
            color: Colors.white,
          ),
        ),
      ),
    );

Widget stopButton(BuildContext context) => Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: _audioPlayerService.handler.stop,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.stop,
            size: 48,
            color: Colors.white,
          ),
        ),
      ),
    );

Widget skipPreviousButton(BuildContext context, {Function()? onPressed}) =>
    IconButton(
      icon: Icon(Icons.skip_previous_rounded),
      iconSize: 48.0,
      onPressed: onPressed,
    );

Widget skipNextButton(BuildContext context, {Function()? onPressed}) =>
    IconButton(
      icon: Icon(Icons.skip_next_rounded),
      iconSize: 48.0,
      onPressed: onPressed,
    );
