import 'package:flutter/material.dart';

/// ラインナップ表示用のデータクラス
/// (アセット画像とファイル画像を統一して扱うため)
class LineupDisplayItem {
  final ImageProvider imageProvider;
  final String name;
  final bool isTightsMan;

  LineupDisplayItem({required this.imageProvider, required this.name, required this.isTightsMan});
}

class FullScreenImageViewer extends StatefulWidget {
  final List<LineupDisplayItem> items;
  final int initialIndex;

  const FullScreenImageViewer({super.key, required this.items, required this.initialIndex});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // 指定されたインデックスから開始するコントローラーを作成
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 半透明のAppBarを重ねて表示
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.items.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image(
                      image: item.imageProvider,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
                      ),
                    ),
                  ),
                ),
                // 画像の名前を下に表示
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (item.isTightsMan)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      '※これは基本キャラクターです。削除できません。',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
