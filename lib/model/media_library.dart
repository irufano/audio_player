import 'package:audio_service/audio_service.dart';

class MediaLibrary {
  static const albumsRootId = 'albums';

  final items = <String, List<MediaItem>>{
    AudioService.browsableRootId: const [
      MediaItem(
        id: albumsRootId,
        title: "Albums",
        playable: false,
      ),
    ],
    albumsRootId: [
      MediaItem(
        // 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3'
        id: '1',
        album: "Sound Helix",
        title: "SoundHelix Song 10 The Examples 1 to 11 are The Same",
        artist: "T. Schürger",
        duration: const Duration(milliseconds: 527000),
        artUri: Uri.parse(
            'https://thumbs.dreamstime.com/b/dynamic-radial-color-sound-equalizer-design-music-album-cover-template-abstract-circular-digital-data-form-vector-160916775.jpg'),
        extras: {
          "source":
              "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3"
        },
      ),
      MediaItem(
        // 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3'
        // 'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'
        id: '2',
        album: "Sound Helix",
        title: "SoundHelix Song 9",
        artist: "T. Schürger",
        duration: const Duration(milliseconds: 389000),
        artUri: Uri.parse(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
        extras: {
          "source":
              "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3"
        },
      ),
      MediaItem(
        // 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3'
        id: '3',
        album: "Sound Helix",
        title: "SoundHelix Song 10 The Examples 1 to 11 are The Same",
        artist: "T. Schürger",
        duration: const Duration(milliseconds: 527000),
        artUri: Uri.parse(
            'https://thumbs.dreamstime.com/b/dynamic-radial-color-sound-equalizer-design-music-album-cover-template-abstract-circular-digital-data-form-vector-160916775.jpg'),
        extras: {
          "source":
              "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3",
          "position": const Duration(milliseconds: 427000)
        },
      ),
    ],
  };
}
