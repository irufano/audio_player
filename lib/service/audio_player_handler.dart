import 'package:audio_player/model/media_library.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

/// An [AudioHandler] for playing a list of audio.
class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  // ignore: close_sinks
  final BehaviorSubject<List<MediaItem>> _recentSubject =
      BehaviorSubject.seeded(<MediaItem>[]);
  final _mediaLibrary = MediaLibrary();
  final _player = AudioPlayer();

  PlaybackState? playbackStateOnStop;

  AudioPlayer get player => _player;

  int? get index => _player.currentIndex;

  List<MediaItem> queueMediaItems = [];
  var _playlist;

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    // // Load and broadcast the queue
    // queue.add(_mediaLibrary.items[MediaLibrary.albumsRootId]!);

    // For Android 11, record the most recent item so it can be resumed.
    mediaItem
        .whereType<MediaItem>()
        .listen((item) => _recentSubject.add([item]));
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) async {
      if (index != null && index < queue.value.length)
        mediaItem.add(queue.value[index]);
    });
    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen((playbackEvent) {
      _broadcastState(playbackEvent);
    });

    // In this example, the service stops when reaching the end.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) stop();
    });
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        // When the user resumes a media session, tell the system what the most
        // recently played item was.
        print("### get recent children: ${_recentSubject.value}:");
        return _recentSubject.value;
      default:
        // Allow client to browse the media library.
        print(
            "### get $parentMediaId children: ${_mediaLibrary.items[parentMediaId]}:");
        return _mediaLibrary.items[parentMediaId]!;
    }
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        return _recentSubject.map((_) => <String, dynamic>{});
      default:
        return Stream.value(_mediaLibrary.items[parentMediaId])
            .map((_) => <String, dynamic>{})
            .shareValue();
    }
  }

  // for single playing
  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    MediaItem media = MediaItem(
      id: DateTime.now().toIso8601String(),
      album: mediaItem.album,
      title: mediaItem.title,
      artist: mediaItem.artist,
      duration: mediaItem.duration,
      artUri: mediaItem.artUri,
      extras: {"source": mediaItem.extras!['source']},
    );
    queueMediaItems.clear();
    queueMediaItems.add(media);
    queue.add(queueMediaItems);

    try {
      print("### _player.load");
      // After a cold restart (on Android), _player.load jumps straight from
      // the loading state to the completed state. Inserting a delay makes it
      // work. Not sure why!
      //await Future.delayed(Duration(seconds: 2)); // magic delay

      if (_playlist == null) {
        // create playlist
        _playlist = ConcatenatingAudioSource(
            children: queueMediaItems
                .asMap()
                .map((index, item) => MapEntry(
                      index,
                      AudioSource.uri(Uri.parse(item.extras!['source'])),
                    ))
                .values
                .toList());

        await _player.setAudioSource(_playlist);
      } else {
        // _playlist is exist
        await _playlist.clear();
        await _playlist
            .add(AudioSource.uri(Uri.parse(media.extras!['source'])));
        await _player.setAudioSource(_playlist);
      }

      print("### loaded");

      if (playbackStateOnStop != null) {
        seek(playbackStateOnStop!.position);
      }

      await play();

      print("### playing");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    MediaItem media = MediaItem(
      id: DateTime.now().toIso8601String(),
      album: mediaItem.album,
      title: mediaItem.title,
      artist: mediaItem.artist,
      duration: mediaItem.duration,
      artUri: mediaItem.artUri,
      extras: {"source": mediaItem.extras!['source']},
    );

    queueMediaItems.add(media);
    queue.add(queueMediaItems);

    try {
      print("### _player.update");
      await _playlist.add(AudioSource.uri(Uri.parse(media.extras!['source'])));

      print("### update loaded");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    // Then default implementations of skipToNext and skipToPrevious provided by
    // the [QueueHandler] mixin will delegate to this method.
    if (index < 0 || index >= queue.value.length) return;
    // This jumps to the beginning of the queue item at newIndex.
    _player.seek(Duration.zero, index: index);
    // Demonstrate custom events.
    customEvent.add('skip to $index');
  }

  @override
  Future<void> play() async {
    print('############ position : ${_player.position} ###############');
    print('############ duration : ${_player.duration} ###############');
    print('############ length : ${_playlist.length} ###############');
    print('############ currentIndex : ${_player.currentIndex} ###########');
    var isLast = _player.currentIndex == (_playlist.length - 1);
    if (isLast && _player.position >= _player.duration!) {
      seek(Duration(milliseconds: 0));
    }

    return _player.play();
  }

  @override
  Future<void> pause() async {
    print('#################### PAUSED ####################');
    print('############### position : ${_player.position} ###############');

    return _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    return _player.seek(position);
  }

  @override
  Future<void> stop() async {
    print('@@@@@@@@@@@@@@@@@@@@@ STOPED @@@@@@@@@@@@@@@@@@@@@@@');
    print('############### position : ${_player.position} ###############');

    await _player.stop();

    playbackStateOnStop = playbackState.value;

    await playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) async {
    print('-------------- PLAYBACK EVENT ------------------');
    print('-------------- position ${_player.position}------');
    print('-------------- buffered ${_player.bufferedPosition}----');

    final playing = _player.playing;

    final current = mediaItem.value ?? MediaItem;
    final first = await queue.isEmpty ? queue.value.first : MediaItem;
    final last = await queue.isEmpty ? queue.value.last : MediaItem;

    print('curent: $current | first queue: $first | last queue: $last');

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }
}
