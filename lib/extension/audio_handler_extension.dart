import 'package:audio_player/locator/locator.dart';
import 'package:audio_player/service/audio_player_service.dart';
import 'package:audio_service/audio_service.dart';

// audio handler using dependency injection
var _audioPlayerService = locator<AudioPlayerService>();

/// Extension methods for our custom actions.
extension AudioHandlerExtension on AudioHandler {
  Future<void> switchToHandler(int? index) async {
    if (index == null) return;
    await _audioPlayerService.handler
        .customAction('switchToHandler', <String, dynamic>{'index': index});
  }
}

