import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gacha_config_controller.g.dart';

class GachaDebugConfig {
  final double ssrWeightMult; // SSRの重み倍率
  final double srWeightMult; // SRの重み倍率
  final double skillProbMult; // スキル付与率の倍率
  final double statusBoost; // ステータス基礎値への加算
  final bool alwaysEffect; // エフェクト確定フラグ

  const GachaDebugConfig({
    this.ssrWeightMult = 1.0,
    this.srWeightMult = 1.0,
    this.skillProbMult = 1.0,
    this.statusBoost = 0.0,
    this.alwaysEffect = false,
  });

  GachaDebugConfig copyWith({
    double? ssrWeightMult,
    double? srWeightMult,
    double? skillProbMult,
    double? statusBoost,
    bool? alwaysEffect,
  }) {
    return GachaDebugConfig(
      ssrWeightMult: ssrWeightMult ?? this.ssrWeightMult,
      srWeightMult: srWeightMult ?? this.srWeightMult,
      skillProbMult: skillProbMult ?? this.skillProbMult,
      statusBoost: statusBoost ?? this.statusBoost,
      alwaysEffect: alwaysEffect ?? this.alwaysEffect,
    );
  }
}

@Riverpod(keepAlive: true)
class GachaConfigController extends _$GachaConfigController {
  @override
  GachaDebugConfig build() {
    return const GachaDebugConfig();
  }

  void setSSRWeight(double val) => state = state.copyWith(ssrWeightMult: val);
  void setSRWeight(double val) => state = state.copyWith(srWeightMult: val);
  void setSkillProb(double val) => state = state.copyWith(skillProbMult: val);
  void setStatusBoost(double val) => state = state.copyWith(statusBoost: val);
  void toggleAlwaysEffect(bool val) => state = state.copyWith(alwaysEffect: val);

  void reset() => state = const GachaDebugConfig();
}
