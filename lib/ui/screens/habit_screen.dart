import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/habit_controller.dart';
import '../../logic/audio_controller.dart';
import '../widgets/level_up_dialog.dart';
// ▼▼▼ 追加: 計算ロジック ▼▼▼
import '../../utils/game_logic/exp_calculator.dart';
import '../widgets/task_completion_dialog.dart';

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  final TextEditingController _titleController = TextEditingController();
  TaskType _selectedType = TaskType.strength;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.low; // 初期値はLowが無難

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // --- ダイアログ表示 (レベル制限対応版) ---
  Future<void> _showEditHabitDialog({Habit? habit}) async {
    final isEditing = habit != null;

    // 1. プレイヤーレベルと解放状況の取得
    final player = ref.read(playerProvider).value;
    final int currentLevel = player?.level ?? 1;

    final bool isNormalUnlocked = currentLevel >= ExpCalculator.unlockLevelMedium;
    final bool isHardUnlocked = currentLevel >= ExpCalculator.unlockLevelHigh;

    // 2. 初期値の設定
    if (isEditing) {
      _titleController.text = habit.name;
      _selectedType = habit.taskType;
      _selectedDifficulty = habit.difficulty;
    } else {
      _titleController.text = '';
      _selectedType = TaskType.strength;
      // 新規作成時、ロックされている難易度が選択されていたらLowに戻す
      if (_selectedDifficulty == TaskDifficulty.normal && !isNormalUnlocked) {
        _selectedDifficulty = TaskDifficulty.low;
      } else if (_selectedDifficulty == TaskDifficulty.high && !isHardUnlocked) {
        _selectedDifficulty = TaskDifficulty.low;
      } else {
        // 前回選択した値を維持しつつ、デフォルトはLow
        _selectedDifficulty = TaskDifficulty.low;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'クエスト編集' : '新しいクエスト'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'クエスト名',
                    hintText: '例: 朝のジョギング',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: false,
                ),
                const SizedBox(height: 16),
                const Text('タイプ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskType>(
                  initialValue: _selectedType, // initialValueではなくvalueを使用
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  dropdownColor: Colors.grey[850], // ドロップダウン背景色
                  items: TaskType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getTaskTypeIcon(type), size: 20, color: _getTaskTypeColor(type)),
                          const SizedBox(width: 8),
                          Text(_getTaskTypeLabel(type)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // 難易度セクション
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('難易度', style: TextStyle(fontWeight: FontWeight.bold)),
                    // レベル表示（デバッグ・確認用）
                    Text('Lv.$currentLevel', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                
                SegmentedButton<TaskDifficulty>(
                  segments: [
                    // Low (常に解放)
                    const ButtonSegment(
                      value: TaskDifficulty.low, 
                      label: Text('低'),
                    ),
                    
                    // Normal (Lv10解放)
                    ButtonSegment(
                      value: TaskDifficulty.normal, 
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('中'),
                          if (!isNormalUnlocked) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock, size: 12),
                          ]
                        ],
                      ),
                      enabled: isNormalUnlocked, // ロック制御
                    ),
                    
                    // High (Lv20解放)
                    ButtonSegment(
                      value: TaskDifficulty.high, 
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('高'),
                          if (!isHardUnlocked) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock, size: 12),
                          ]
                        ],
                      ),
                      enabled: isHardUnlocked, // ロック制御
                    ),
                  ],
                  selected: {_selectedDifficulty},
                  onSelectionChanged: (Set<TaskDifficulty> newSelection) {
                    setDialogState(() => _selectedDifficulty = newSelection.first);
                  },
                  style: ButtonStyle(
                    // ロック時の色調整などがしたければここで設定
                  ),
                ),
                
                // 解放条件のヒントテキスト
                if (!isHardUnlocked) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      !isNormalUnlocked 
                          ? "※ Lv.${ExpCalculator.unlockLevelMedium}で「中」解放"
                          : "※ Lv.${ExpCalculator.unlockLevelHigh}で「高」解放",
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(isEditing ? '更新' : '追加'),
            ),
          ],
        ),
      ),
    );

    if (result == true && _titleController.text.trim().isNotEmpty) {
      if (isEditing) {
        await ref
            .read(habitControllerProvider.notifier)
            .updateHabit(
              habit: habit,
              title: _titleController.text.trim(),
              type: _selectedType,
              difficulty: _selectedDifficulty,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('クエストを更新しました！'), backgroundColor: Colors.green),
          );
        }
      } else {
        await ref
            .read(habitControllerProvider.notifier)
            .addHabit(
              title: _titleController.text.trim(),
              type: _selectedType,
              difficulty: _selectedDifficulty,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('クエストを追加しました！'), backgroundColor: Colors.green),
          );
        }
      }
    }
  }

  // --- 完了処理 (アニメーションダイアログ版) ---
  Future<void> _completeHabit(Habit habit) async {
    // 1. リポジトリで完了処理を実行
    final result = await ref.read(habitRepositoryProvider).completeHabit(habit);

    if (mounted) {
      // 2. SE再生
      ref.read(audioControllerProvider.notifier).playCompleteSE();

      // 3. 最新のプレイヤーデータを取得 (チャート表示用)
      // completeHabit内でDBは更新されているので、再取得する
      final db = ref.read(databaseProvider);
      final player = await (db.select(db.players)..where((p) => p.id.equals(1))).getSingle();

      // 4. 称号獲得チェック
      final newTitles = result['newTitles'] as List<String>? ?? [];
      if (newTitles.isNotEmpty) {
        // 称号は別途スナックバーで通知 (ダイアログと被らないように)
        final titleText = newTitles.join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('称号獲得！「$titleText」')),
              ],
            ),
            backgroundColor: Colors.amber[800],
          ),
        );
        ref.read(audioControllerProvider.notifier).playLevelUpSE();
      }

      // 5. レベルアップチェック
      final isLevelUp = result['levelUp'] == 1;
      if (isLevelUp) {
        // レベルアップ時は、既存のレベルアップダイアログを優先表示
        HapticFeedback.heavyImpact();
        ref.read(audioControllerProvider.notifier).playLevelUpSE();
        if (mounted) {
          await showDialog( // awaitで閉じるまで待つ
            context: context,
            barrierDismissible: false,
            builder: (context) => LevelUpDialog(
              player: player,  
              result: result,  
              onClosed: () {},
            ),
          );
        }
        // レベルアップダイアログ後に、さらにタスク完了ダイアログを出すかは選択の余地あり。
        // 今回は「レベルアップのインパクトを優先」し、ここではタスク完了ダイアログは出さない方針とします。
        // もし両方出したい場合は、ここでの return を外してください。
        return; 
      }

      // 6. 通常のタスク完了ダイアログを表示
      if (mounted) {
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          // 背景タップで閉じられないようにする（アニメーションをしっかり見せるため）
          barrierDismissible: false, 
          builder: (context) => TaskCompletionDialog(
            habit: habit,
            player: player,
            result: result,
          ),
        );
      }
    }
  }

  // --- 削除処理 ---
  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クエスト削除'),
        content: Text('「${habit.name}」を削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('クエストを削除しました')));
      }
    }
  }

  // --- メニュー表示 ---
  void _showHabitActionMenu(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集'),
              onTap: () {
                Navigator.pop(context);
                _showEditHabitDialog(habit: habit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('削除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteHabit(habit);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final habitState = ref.watch(habitControllerProvider);
    
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final onPrimaryColor = colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('クエスト'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('クエストを追加して始めましょう！', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final incompleteHabits = habits.where((h) => !h.isCompleted).toList();
          final completedHabits = habits.where((h) => h.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (incompleteHabits.isNotEmpty) ...[
                const Text(
                  '進行中',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...incompleteHabits.map(
                  (habit) => _buildHabitCard(habit, false, habitState.isLoading),
                ),
                const SizedBox(height: 24),
              ],
              if (completedHabits.isNotEmpty) ...[
                const Text(
                  '完了済み',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...completedHabits.map(
                  (habit) => _buildHabitCard(habit, true, habitState.isLoading),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('エラーが発生しました')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: habitState.isLoading ? null : () => _showEditHabitDialog(),
        icon: const Icon(Icons.add_task),
        label: const Text('クエスト追加'),
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, bool isCompleted, bool isLoading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCompleted ? Colors.grey[900] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTaskTypeColor(habit.taskType).withOpacity(0.3),
          child: Icon(_getTaskTypeIcon(habit.taskType), color: _getTaskTypeColor(habit.taskType)),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.white,
          ),
        ),
        subtitle: Row(
          children: [
            Chip(
              label: Text(_getTaskTypeLabel(habit.taskType), style: const TextStyle(fontSize: 10)),
              backgroundColor: _getTaskTypeColor(habit.taskType).withOpacity(0.2),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Text(
              '${habit.rewardGems}G / ${habit.rewardXp}XP',
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: isLoading ? null : () => _completeHabit(habit),
                tooltip: '完了',
              ),
        onLongPress: () => _showHabitActionMenu(habit),
      ),
    );
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.strength: return Icons.fitness_center;
      case TaskType.intelligence: return Icons.school;
      case TaskType.luck: return Icons.casino;
      case TaskType.charm: return Icons.favorite;
      case TaskType.vitality: return Icons.directions_run;
    }
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.strength: return 'STR';
      case TaskType.intelligence: return 'INT';
      case TaskType.luck: return 'LUK';
      case TaskType.charm: return 'CHA';
      case TaskType.vitality: return 'VIT';
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.strength: return Colors.red;
      case TaskType.vitality: return Colors.orange;
      case TaskType.intelligence: return Colors.blue;
      case TaskType.luck: return Colors.purple;
      case TaskType.charm: return Colors.pink;
    }
  }
}