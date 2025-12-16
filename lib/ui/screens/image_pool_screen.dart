// lib/ui/screens/image_pool_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift; // drift用エイリアス

import '../../data/database/database.dart';
import '../../data/providers.dart';
import 'image_crop_screen.dart';

class ImagePoolScreen extends ConsumerWidget {
  final bool isSelectionMode;

  const ImagePoolScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final imagesStream = db.select(db.characterImages).watch();

    return Scaffold(
      appBar: AppBar(title: Text(isSelectionMode ? '画像を選択' : 'ガチャ画像プール設定')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndAddImage(context, ref),
        child: const Icon(Icons.add_photo_alternate),
      ),
      body: StreamBuilder<List<CharacterImage>>(
        stream: imagesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final images = snapshot.data!;

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'ガチャ用画像がありません\n右下のボタンから追加してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final img = images[index];
              return GestureDetector(
                // タップ時: 選択モードなら選択して戻る
                onTap: isSelectionMode
                    ? () {
                        Navigator.pop(context, img.imagePath);
                      }
                    : null,

                // ✅ 追加: 長押しで編集（名前変更・トリミングやり直し）
                onLongPress: () => _editImage(context, ref, img),

                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(img.imagePath), fit: BoxFit.cover),
                    ),

                    // 名前ラベル (下部に表示)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        color: Colors.black54,
                        child: Text(
                          img.name,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // 削除ボタン (管理モード時のみ)
                    if (!isSelectionMode)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            onPressed: () => _confirmDelete(context, db, img),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 新規追加
  Future<void> _pickAndAddImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImageCropScreen(pickedPath: pickedFile.path)),
      );

      if (result != null && result is Map) {
        final savedPath = result['path'] as String;
        final name = result['name'] as String;

        final db = ref.read(databaseProvider);
        try {
          await db
              .into(db.characterImages)
              .insert(
                CharacterImagesCompanion.insert(imagePath: savedPath, name: drift.Value(name)),
              );
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('「$name」をプールに追加しました')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('登録エラー: $e'), backgroundColor: Colors.red));
          }
        }
      }
    }
  }

  // ✅ 追加: 既存画像の編集 (長押しで呼び出し)
  Future<void> _editImage(BuildContext context, WidgetRef ref, CharacterImage img) async {
    // 編集画面へ遷移（現在のパスと名前を渡す）
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(
          pickedPath: img.imagePath, // 既存の画像パス
          initialName: img.name, // 既存の名前
        ),
      ),
    );

    // 更新処理
    if (result != null && result is Map) {
      final newPath = result['path'] as String;
      final newName = result['name'] as String;

      final db = ref.read(databaseProvider);
      try {
        // IDを指定して更新
        await (db.update(db.characterImages)..where((t) => t.id.equals(img.id))).write(
          CharacterImagesCompanion(imagePath: drift.Value(newPath), name: drift.Value(newName)),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('画像を更新しました')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('更新エラー: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppDatabase db, CharacterImage img) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('画像を削除'),
        content: const Text('この画像をプールから削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      await (db.delete(db.characterImages)..where((t) => t.id.equals(img.id))).go();
    }
  }
}
