import 'package:audio_player/service/audio_player_handler.dart';
import 'package:audio_player/service/main_switch_handler.dart';
import 'package:audio_service/audio_service.dart';

import 'logging_audio_handler.dart';

class AudioPlayerService {
  late AudioHandler handler;

  Future<dynamic> setup() async {
    handler = await AudioService.init(
      builder: () => LoggingAudioHandler(
        MainSwitchHandler([
          AudioPlayerHandler(),
        ]),
      ),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}
