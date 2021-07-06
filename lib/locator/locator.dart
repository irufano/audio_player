import 'package:audio_player/service/audio_player_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // locator.registerLazySingleton<Object>(() => NavigationService());

  locator.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
}
