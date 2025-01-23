import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaySound {
  static const String _soundPrefKey = 'villager_sound_enabled';

  var logger = Logger();

  static const Map<String, String> sounds = {
    'death': 'sounds/villager-death.mp3',
    'hit': 'sounds/villager-hit.mp3',
    'simple1': 'sounds/villager-simple-1.mp3',
    'simple2': 'sounds/villager-simple-2.mp3',
    'skibidi': 'sounds/villager-skibidi.mp3',
  };


  final AudioPlayer _audioPlayer = AudioPlayer();

  // Vérifie si le son Villager est activé
  Future<bool> _isSoundEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundPrefKey) ?? false;
  }

  // Joue un son donné (par clé)
  Future<void> play(String soundKey) async {
    // Vérifier si le son est activé
    bool isEnabled = await _isSoundEnabled();
    if (!isEnabled) {
      logger.d('Sound is disabled');
      return; // Si désactivé, ne rien faire
    }

    // Récupérer le chemin du son
    String? soundPath = sounds[soundKey];
    if (soundPath != null) {
      await _audioPlayer.play(AssetSource(soundPath));
      logger.d('Playing sound: $soundKey');
    }
  }
}
