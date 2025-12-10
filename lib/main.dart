import 'package:drift/drift.dart' as drift; // driftのエイリアスを追加
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database/database.dart';
import 'data/providers.dart'; // databaseProviderのためにインポート
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // プロバイダーコンテナを作成してDB操作を行えるようにする
  final container = ProviderContainer();
  await _ensurePlayerData(container);

  runApp(UncontrolledProviderScope(container: container, child: const OshiQuestApp()));
}

/// プレイヤーデータが存在するか確認し、なければ作成する
Future<void> _ensurePlayerData(ProviderContainer container) async {
  final db = container.read(databaseProvider);
  try {
    // ID=1のプレイヤーを探す
    final player = await (db.select(db.players)..where((p) => p.id.equals(1))).getSingleOrNull();

    if (player == null) {
      print('⚠️ プレイヤーデータが見つかりません。初期データを作成します。');
      // 初期プレイヤーデータの作成
      await db
          .into(db.players)
          .insert(
            PlayersCompanion.insert(
              id: const drift.Value(1), // IDを1に固定
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
      print('✅ プレイヤーデータを作成しました。');
    }
  } catch (e) {
    print('❌ データチェック中にエラーが発生しました: $e');
  }
}

class OshiQuestApp extends StatelessWidget {
  const OshiQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OshiQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
