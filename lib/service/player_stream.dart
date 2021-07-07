import 'package:audio_player/locator/locator.dart';
import 'package:audio_player/model/media_state.dart';
import 'package:audio_player/model/queue_state.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_player_service.dart';

// audio handler using dependency injection
var _audioPlayerService = locator<AudioPlayerService>();

class PlayerStream {
  // Stream current media item, current position and its buffered positionq
  Stream<MediaState> get mediaStateStream =>
      Rx.combineLatest3<MediaItem?, Duration, Duration, MediaState>(
          _audioPlayerService.handler.mediaItem,
          AudioService.position,
          _audioPlayerService.handler.playbackState
              .map((state) => state.bufferedPosition)
              .distinct(),
          (mediaItem, position, bufferedPosition) =>
              MediaState(mediaItem, position, bufferedPosition));

  // Stream current queue and the current media item within that queue.
  Stream<QueueState> get queueStateStream =>
      Rx.combineLatest2<List<MediaItem>?, MediaItem?, QueueState>(
          _audioPlayerService.handler.queue,
          _audioPlayerService.handler.mediaItem,
          (queue, mediaItem) => QueueState(queue, mediaItem));

  // Stream playing
  Stream<bool> get playingStream => _audioPlayerService.handler.playbackState
      .map((state) => state.playing)
      .distinct();
}

final PlayerStream playerStream = PlayerStream();
