import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart'; // databaseProviderのためにimport

class GrowthForecastChart extends ConsumerWidget {
  const GrowthForecastChart({super.key});

  static const int kTotalPoints = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    
    return StreamBuilder<Player>(
      stream: db.select(db.players).watchSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final p = snapshot.data!;
        
        final strExp = p.tempStrExp;
        final intExp = p.tempIntExp;
        final lukExp = p.tempLukExp;
        final chaExp = p.tempChaExp;
        final vitExp = p.tempVitExp;
        final totalExp = strExp + intExp + lukExp + chaExp + vitExp;

        // --- 値の計算 (0除算対策) ---
        double pStr = 0, pInt = 0, pLuk = 0, pCha = 0, pVit = 0;

        if (totalExp > 0) {
          pStr = (kTotalPoints * (strExp / totalExp));
          pInt = (kTotalPoints * (intExp / totalExp));
          pLuk = (kTotalPoints * (lukExp / totalExp));
          pCha = (kTotalPoints * (chaExp / totalExp));
          pVit = (kTotalPoints * (vitExp / totalExp));
        }

        // 表示用の整数値 (floor)
        final dStr = pStr.floor();
        final dInt = pInt.floor();
        final dLuk = pLuk.floor();
        final dCha = pCha.floor();
        final dVit = pVit.floor();

        return Container(
          // 外側のマージンと装飾を削除（親のボックスに合わせるため）
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 中央揃えに変更
            mainAxisSize: MainAxisSize.min,
            children: [
              // タイトル
              const Text(
                "成長予報 (Next Bonus)",
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // --- 1. レーダーチャート (上に配置) ---
              SizedBox(
                width: 110, // 少し小さく (120 -> 110)
                height: 110,
                child: RadarChart(
                  RadarChartData(
                    radarTouchData: RadarTouchData(enabled: false),
                    dataSets: [
                      RadarDataSet(
                        fillColor: Colors.cyanAccent.withOpacity(0.2),
                        borderColor: Colors.cyanAccent.withOpacity(0.8),
                        entryRadius: 2,
                        dataEntries: [
                          RadarEntry(value: pStr.isNaN ? 0.0 : pStr),
                          RadarEntry(value: pInt.isNaN ? 0.0 : pInt),
                          RadarEntry(value: pLuk.isNaN ? 0.0 : pLuk),
                          RadarEntry(value: pCha.isNaN ? 0.0 : pCha),
                          RadarEntry(value: pVit.isNaN ? 0.0 : pVit),
                        ],
                        borderWidth: 1.5,
                      ),
                    ],
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(color: Colors.transparent),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: const TextStyle(color: Colors.white38, fontSize: 9),
                    
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0: return const RadarChartTitle(text: 'STR');
                        case 1: return const RadarChartTitle(text: 'INT');
                        case 2: return const RadarChartTitle(text: 'LUK');
                        case 3: return const RadarChartTitle(text: 'CHA');
                        case 4: return const RadarChartTitle(text: 'VIT');
                        default: return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 2,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    tickBorderData: const BorderSide(color: Colors.white10),
                    gridBorderData: const BorderSide(color: Colors.white12, width: 0.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 16), // 上下の間隔

              // --- 2. 数値リスト (下に配置) ---
              // Expandedをやめて、そのまま配置
              Column(
                children: [
                  _buildStatRow('STR', dStr, Colors.redAccent),
                  _buildStatRow('VIT', dVit, Colors.orangeAccent),
                  _buildStatRow('INT', dInt, Colors.blueAccent),
                  _buildStatRow('LUK', dLuk, Colors.purpleAccent),
                  _buildStatRow('CHA', dCha, Colors.pinkAccent),
                  
                  const SizedBox(height: 8),
                  Text(
                    totalExp == 0 ? "データ蓄積中..." : "傾向分析完了",
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1), // 間隔を詰める
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 30, // ラベル幅を固定
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
          Text(
            "+$value",
            style: TextStyle(
              color: value > 0 ? Colors.cyanAccent : Colors.white24,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}