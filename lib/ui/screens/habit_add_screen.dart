import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../utils/game_logic/exp_calculator.dart';

class HabitAddScreen extends ConsumerStatefulWidget {
  const HabitAddScreen({super.key});

  @override
  ConsumerState<HabitAddScreen> createState() => _HabitAddScreenState();
}

class _HabitAddScreenState extends ConsumerState<HabitAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  // 初期値設定
  TaskType _selectedType = TaskType.strength;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.low; 

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // プレイヤーの現在のレベルを取得
    final playerAsync = ref.watch(playerProvider);
    final int currentLevel = playerAsync.value?.level ?? 1;

    // 解放条件チェック (ExpCalculatorの定数を使用)
    final bool isNormalUnlocked = currentLevel >= ExpCalculator.unlockLevelMedium;
    final bool isHardUnlocked = currentLevel >= ExpCalculator.unlockLevelHigh;

    return Scaffold(
      appBar: AppBar(title: const Text('新規クエスト作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // タイトル入力
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'クエスト名',
                  hintText: '例: 筋トレ30分、読書など',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? '入力してください' : null,
              ),
              const SizedBox(height: 24),

              // タスクタイプ選択
              const Text('ステータスタイプ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<TaskType>(
                value: _selectedType,
                dropdownColor: Colors.grey[850],
                isExpanded: true,
                items: TaskType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              
              const SizedBox(height: 24),

              // 難易度選択 (解放されていない難易度は非表示)
              const Text('難易度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // ✅ Low: 常に表示
                    _buildDifficultyTile(
                      title: '低 (Low)',
                      subtitle: '基本報酬: 10 EXP / 5 Gems',
                      value: TaskDifficulty.low,
                      groupValue: _selectedDifficulty,
                      onChanged: (val) => setState(() => _selectedDifficulty = val!),
                    ),

                    // ✅ Normal: 解放済みなら表示
                    if (isNormalUnlocked) ...[
                      const Divider(height: 1),
                      _buildDifficultyTile(
                        title: '中 (Normal)',
                        subtitle: '基本報酬: 50 EXP / 25 Gems',
                        value: TaskDifficulty.normal,
                        groupValue: _selectedDifficulty,
                        onChanged: (val) => setState(() => _selectedDifficulty = val!),
                      ),
                    ],

                    // ✅ Hard: 解放済みなら表示
                    if (isHardUnlocked) ...[
                      const Divider(height: 1),
                      _buildDifficultyTile(
                        title: '高 (Hard)',
                        subtitle: '基本報酬: 200 EXP / 100 Gems',
                        value: TaskDifficulty.high,
                        groupValue: _selectedDifficulty,
                        onChanged: (val) => setState(() => _selectedDifficulty = val!),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 次の解放レベルのヒントを表示
              if (!isHardUnlocked) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    !isNormalUnlocked 
                        ? "※ Lv.${ExpCalculator.unlockLevelMedium} で「中」難易度が解放されます"
                        : "※ Lv.${ExpCalculator.unlockLevelHigh} で「高」難易度が解放されます",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              
              // 決定ボタン
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref.read(habitRepositoryProvider).addHabit(
                          _titleController.text,
                          _selectedType,
                          _selectedDifficulty,
                        );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('クエスト受注', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // シンプルなタイル (非表示制御なのでRadioListTileでOK)
  Widget _buildDifficultyTile({
    required String title,
    required String subtitle,
    required TaskDifficulty value,
    required TaskDifficulty groupValue,
    required ValueChanged<TaskDifficulty?>? onChanged,
  }) {
    return RadioListTile<TaskDifficulty>(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.cyanAccent,
    );
  }
}