// lib/ui/screens/image_crop_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageCropScreen extends StatefulWidget {
  final String pickedPath;
  final String? initialName; // ✅ 追加: 編集時の初期名前

  const ImageCropScreen({
    super.key,
    required this.pickedPath,
    this.initialName, // ✅ 追加
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  late TextEditingController _nameController; // lateに変更

  @override
  void initState() {
    super.initState();
    // ✅ 初期値があればセット、なければ空
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<String?> _cropAndSaveImage(BuildContext context) async {
    final pickedFile = File(widget.pickedPath);

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '画像をトリミング (9:16)',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: '画像をトリミング (9:16)',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      // ファイル名を更新日時で新しく作り直す（キャッシュ回避にもなる）
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_cropped_${p.basename(croppedFile.path)}';
      final savedFile = await File(croppedFile.path).copy('${appDir.path}/$fileName');
      return savedFile.path;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.initialName != null ? '編集: 名前と画像' : '名前と画像の設定'), // タイトルを動的に
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.cyanAccent),
            onPressed: () async {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('名前を入力してください')),
                );
                return;
              }

              try {
                // トリミング実行
                final savedPath = await _cropAndSaveImage(context);
                
                // トリミングが成功した場合、またはトリミングせず既存パスを使う場合(今回は必ずトリミングを通す仕様)
                if (savedPath != null && mounted) {
                  Navigator.pop(context, <String, String>{
                    'path': savedPath,
                    'name': _nameController.text,
                  });
                } else if (savedPath == null) {
                   // キャンセルされた場合
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 400,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  File(widget.pickedPath),
                  fit: BoxFit.contain,
                  errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
        
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'キャラクター名',
                  labelStyle: const TextStyle(color: Colors.cyanAccent),
                  hintText: '例: 推しメンA',
                  hintStyle: const TextStyle(color: Colors.white24),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.cyanAccent),
                ),
              ),
              
              const SizedBox(height: 16),
              const Text(
                '右上のチェックボタンをタップして\nトリミングへ進んでください',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}