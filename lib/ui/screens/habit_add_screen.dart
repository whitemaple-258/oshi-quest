import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../logic/habit_controller.dart';

class HabitAddScreen extends ConsumerStatefulWidget {
  // Widgetツリーで再利用可能にするためconstコンストラクタを使用
  const HabitAddScreen({super.key});

  @override
  ConsumerState<HabitAddScreen> createState() => _HabitAddScreenState();
}

class _HabitAddScreenState extends ConsumerState<HabitAddScreen> {
  final _formKey = GlobalKey<FormState>();
  // TextEditingControllerはRenderObjectには直接影響しないが、入力のたびにリビルドを走らせないように注意
  late final TextEditingController _titleController;

  TaskType _selectedType = TaskType.strength;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.normal;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // ref.readを使用し、ビルドの監視を行わない（イベント発火時のみ参照）
      await ref
          .read(habitControllerProvider.notifier)
          .addHabit(
            title: _titleController.text,
            type: _selectedType,
            difficulty: _selectedDifficulty,
          );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // constを使用することで、親Widgetがリビルドされても
    // この以下のサブツリーはElementが更新処理をスキップできる
    return Scaffold(
      appBar: AppBar(title: const Text('新規クエスト登録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. タスク名入力
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'クエスト名（習慣）',
                  hintText: '例：スクワット20回、読書30分',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'クエスト名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 2. タスクタイプ選択
              const Text('強化するステータス (Type)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<TaskType>(
                // segmentsリスト自体もconst化可能
                segments: const [
                  ButtonSegment(
                    value: TaskType.strength,
                    label: Text('STR'),
                    icon: Icon(Icons.fitness_center),
                  ),
                  ButtonSegment(
                    value: TaskType.intelligence,
                    label: Text('INT'),
                    icon: Icon(Icons.school),
                  ),
                  ButtonSegment(
                    value: TaskType.luck,
                    label: Text('LUCK'),
                    icon: Icon(Icons.casino),
                  ),
                  ButtonSegment(
                    value: TaskType.charm,
                    label: Text('CHA'),
                    icon: Icon(Icons.favorite),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TaskType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                showSelectedIcon: false,
              ),
              const SizedBox(height: 24),

              // 3. 難易度選択
              const Text('難易度 (Difficulty)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskDifficulty>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                // itemsの中身も可能な限りconst化
                items: TaskDifficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text('${difficulty.name.toUpperCase()} (報酬倍率が変わります)'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // 4. 登録ボタン
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add_task),
                label: const Text('クエストボードに掲示する'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
