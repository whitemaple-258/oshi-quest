import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database/database.dart';
import 'data/providers.dart'; // ✅ providers.dart をインポート
import 'ui/screens/main_screen.dart';

/// アプリの初期化処理を行うプロバイダー
final appInitializationProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  print('🚀 初期化チェック開始...');

  try {
    // 1. プレイヤーデータ(ID=1)の確認・作成
    final player = await (db.select(db.players)..where((p) => p.id.equals(1))).getSingleOrNull();

    if (player == null) {
      print('⚠️ プレイヤーデータがありません。新規作成します...');
      await db
          .into(db.players)
          .insert(
            PlayersCompanion.insert(
              id: const drift.Value(1),
              level: const drift.Value(1),
              willGems: const drift.Value(500),
              experience: const drift.Value(0),
              str: const drift.Value(0),
              intellect: const drift.Value(0),
              luck: const drift.Value(0),
              cha: const drift.Value(0),
              createdAt: drift.Value(DateTime.now()),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
      print('✅ プレイヤーデータ(ID:1)を作成しました！');
    } else {
      print('✅ プレイヤーデータ確認OK (Lv.${player.level})');
    }

    // 2. 称号マスターデータの初期化
    final titleRepo = ref.read(titleRepositoryProvider);
    await titleRepo.initMasterData();
    print('✅ 称号データチェック完了');
  } catch (e, stack) {
    print('❌ 初期化エラー発生: $e');
    print(stack);
    rethrow;
  }
});

void main() {
  runApp(const ProviderScope(child: OshiQuestApp()));
}

class OshiQuestApp extends ConsumerWidget {
  const OshiQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初期化処理を監視
    final initAsync = ref.watch(appInitializationProvider);

    return MaterialApp(
      title: 'OshiQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      // 初期化状態に応じて画面を切り替え
      home: initAsync.when(
        data: (_) => const MainScreen(), // 完了したらメイン画面へ
        loading: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('データを準備中...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '起動エラーが発生しました',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(error.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
