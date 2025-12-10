import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'audio_controller.g.dart';

@Riverpod(keepAlive: true)
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

  /// タスク完了SEを再生（安全版）
  Future<void> playCompleteSE() async {
    try {
      if (_player.state == PlayerState.playing) {
        await _player.stop();
      }
      // 音量は 0.0 ~ 1.0 で設定可能（ここでは0.5）
      await _player.setVolume(0.5);
      await _player.play(AssetSource('sounds/task_complete.mp3'));
    } catch (e) {
      // エラーが起きてもアプリを止めずにログだけ出す
      print('⚠️ 音声再生エラー (Complete): $e');
    }
  }

  /// レベルアップSEを再生（安全版）
  Future<void> playLevelUpSE() async {
    try {
      if (_player.state == PlayerState.playing) {
        await _player.stop();
      }
      await _player.setVolume(0.5);
      await _player.play(AssetSource('sounds/level_up.mp3'));
    } catch (e) {
      print('⚠️ 音声再生エラー (LevelUp): $e');
    }
  }

  /// ガチャ演出中のドラムロール
  Future<void> playGachaDrum() async {
    await _player.stop();
    await _player.setVolume(0.5);
    // ループ再生しない場合は play でOK（長さ分だけ鳴る）
    await _player.play(AssetSource('sounds/gacha_drum.mp3'));
  }

  /// ガチャ結果表示音（ドラムロールを止めて鳴らす）
  Future<void> playGachaResult() async {
    await _player.stop(); // ドラムロールを強制停止
    await _player.setVolume(0.5);
    await _player.play(AssetSource('sounds/gacha_result.mp3'));
  }
}
