import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_controller.g.dart';

@riverpod
class AudioController extends _$AudioController {
  late final AudioPlayer _player;

  @override
  void build() {
    _player = AudioPlayer();
    // プレイヤーの破棄時にリソースを開放
    ref.onDispose(() {
      _player.dispose();
    });
  }

  /// タスク完了SEを再生
  Future<void> playCompleteSE() async {
    // 連続再生に対応するため、再生ごとにモードを設定（必要に応じて調整）
    await _player.stop();
    await _player.play(AssetSource('sounds/task_complete.mp3'));
  }

  /// レベルアップSEを再生
  Future<void> playLevelUpSE() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/level_up.mp3'));
  }

  /// ガチャSEを再生（オプション）
  Future<void> playGachaSE() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/gacha_pull.mp3'));
  }
}
