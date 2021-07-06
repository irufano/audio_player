import 'package:audio_service/audio_service.dart';

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final Duration bufferedPosition;

  MediaState(this.mediaItem, this.position, this.bufferedPosition);
}
