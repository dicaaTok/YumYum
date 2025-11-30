import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart'; // optional: если используешь Hive
import 'package:http/http.dart' as http;

// NOTE:
// - Если в проекте нет пакетa intl / http / hive — добавь их в pubspec.yaml.
// - Для реальных вызовов ИИ замените _fetchAiAdvice и _askAi на реальные вызовы HFService/Backend.

class MyGoalScreen extends StatefulWidget {
  const MyGoalScreen({Key? key}) : super(key: key);

  @override
  State<MyGoalScreen> createState() => _MyGoalScreenState();
}

enum GoalType { loseWeight, gainWeight, maintain, nutrientFocus }

class Goal {
  GoalType type;
  double? targetWeight;
  DateTime? targetDate;
  List<String> nutrients; // e.g. ['Protein','Calcium']
  Goal({
    required this.type,
    this.targetWeight,
    this.targetDate,
    this.nutrients = const [],
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'targetWeight': targetWeight,
    'targetDate': targetDate?.toIso8601String(),
    'nutrients': nutrients,
  };

  static Goal fromJson(Map<String, dynamic> j) {
    GoalType parse(String s) {
      if (s.contains('loseWeight')) return GoalType.loseWeight;
      if (s.contains('gainWeight')) return GoalType.gainWeight;
      if (s.contains('maintain')) return GoalType.maintain;
      return GoalType.nutrientFocus;
    }

    return Goal(
      type: parse(j['type'] ?? ''),
      targetWeight: (j['targetWeight'] as num?)?.toDouble(),
      targetDate: j['targetDate'] != null ? DateTime.parse(j['targetDate']) : null,
      nutrients: List<String>.from(j['nutrients'] ?? []),
    );
  }
}

class ProgressEntry {
  DateTime date;
  double? weight;
  String? note;
  ProgressEntry({required this.date, this.weight, this.note});
}

class _MyGoalScreenState extends State<MyGoalScreen> {
  // UI state
  Goal _goal = Goal(type: GoalType.loseWeight, nutrients: []);
  final _weightController = TextEditingController();
  DateTime? _selectedTargetDate;

  // Progress
  final List<ProgressEntry> _progress = [];

  // Chat
  final List<Map<String, String>> _chat = []; // {'role':'user'/'ai', 'text':'...'}
  final TextEditingController _chatController = TextEditingController();

  // Calendar window (last 14 days)
  final int _daysWindow = 14;

  // Optional Hive boxes (if you use Hive)
  Box? _goalBox;
  Box? _progressBox;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      if (Hive.isBoxOpen('myGoal')) {
        _goalBox = Hive.box('myGoal');
      } else if (await _tryOpenBoxSafe('myGoal')) {
        _goalBox = Hive.box('myGoal');
      }

      if (_goalBox != null && _goalBox!.isNotEmpty) {
        final raw = _goalBox!.get('goal') as String?;
        if (raw != null) {
          setState(() {
            _goal = Goal.fromJson(jsonDecode(raw));
            _selectedTargetDate = _goal.targetDate;
            _weightController.text = _goal.targetWeight?.toString() ?? '';
          });
        }
      }

      if (await _tryOpenBoxSafe('progress')) {
        _progressBox = Hive.box('progress');
        final saved = _progressBox!.get('entries') as List<dynamic>?;
        if (saved != null) {
          setState(() {
            _progress.clear();
            for (var e in saved) {
              _progress.add(ProgressEntry(
                date: DateTime.parse(e['date']),
                weight: (e['weight'] as num?)?.toDouble(),
                note: e['note'],
              ));
            }
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Hive load failed (maybe Hive not initialized): $e");
    }
  }

  Future<bool> _tryOpenBoxSafe(String name) async {
    try {
      if (!Hive.isBoxOpen(name)) await Hive.openBox(name);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveGoal() async {
    _goal.targetWeight = double.tryParse(_weightController.text);
    _goal.targetDate = _selectedTargetDate;
    // save to hive if possible
    if (_goalBox != null) {
      await _goalBox!.put('goal', jsonEncode(_goal.toJson()));
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Цель сохранена')));
  }

  Future<void> _addProgressEntry() async {
    final now = DateTime.now();
    double? w;
    try {
      w = double.tryParse(_weightController.text);
    } catch (_) {}
    final entry = ProgressEntry(date: now, weight: w, note: null);
    setState(() {
      _progress.add(entry);
    });
    // persist
    if (_progressBox != null) {
      final serial = _progress.map((e) => {'date': e.date.toIso8601String(), 'weight': e.weight, 'note': e.note}).toList();
      await _progressBox!.put('entries', serial);
    }
  }

  /// ---------- AI integration stubs ----------
  /// Replace these with real calls to HFService or your backend.
  Future<String> _fetchAiAdvice() async {
    // Example: POST to your backend with goal details and get a recipe+instructions
    // return await HFService.getRecipeForGoal(_goal);
    // Placeholder: simulate network
    await Future.delayed(const Duration(seconds: 1));
    // Example reply (should be replaced with API result)
    return "Сегодня рекомендую приготовить гречневую кашу с куриной грудкой: 1) отварить гречку, 2) обжарить куриную грудку и добавить овощи. Калории ~450 ккал. Подробный рецепт: ...";
  }

  Future<String> _askAi(String question) async {
    // Replace with your hf service call, e.g. HFService.ask(question, context: _goal)
    await Future.delayed(const Duration(milliseconds: 500));
    return "Ответ ИИ: для достижения цели обратите внимание на размер порций, цель белка — 1.6 г/кг...";
  }

  /// Example direct HuggingFace usage (if you want to call HF inference API from the app).
  /// WARNING: embedding API key in app is insecure. Prefer server-side.
  Future<String> _callHuggingFaceTextGeneration(String prompt) async {
    const apiUrl = 'https://api-inference.huggingface.co/models/gpt2'; // example
    const hfApiKey = 'REPLACE_WITH_SERVER_SIDE_KEY';
    final res = await http.post(Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $hfApiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'inputs': prompt}));
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      // parse per model
      if (j is Map && j['generated_text'] != null) return j['generated_text'];
      if (j is List && j.isNotEmpty && j[0]['generated_text'] != null) return j[0]['generated_text'];
      return res.body;
    } else {
      return 'Ошибка при запросе ИИ: ${res.statusCode}';
    }
  }

  /// ---------- UI helpers ----------
  List<DateTime> _buildWindowDates() {
    final now = DateTime.now();
    return List.generate(_daysWindow, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: _daysWindow - 1 - i)));
  }

  double? _getWeightForDate(DateTime date) {
    for (var e in _progress.reversed) {
      if (_isSameDay(e.date, date)) return e.weight;
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Simple sparkline painter
  Widget _buildSparkline() {
    final dates = _buildWindowDates();
    final values = dates.map((d) => _getWeightForDate(d) ?? double.nan).toList();
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _SparklinePainter(values),
        size: const Size(double.infinity, 80),
      ),
    );
  }

  void _onSendChat() async {
    final question = _chatController.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _chat.add({'role': 'user', 'text': question});
      _chatController.clear();
    });
    final answer = await _askAi(question);
    setState(() {
      _chat.add({'role': 'ai', 'text': answer});
    });
  }

  void _onGetAdvice() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Запрос к ИИ...')));
    final advice = await _fetchAiAdvice();
    setState(() {
      _chat.add({'role': 'ai', 'text': advice});
    });
    // Optionally show a dialog with full recipe
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Совет от ИИ / Рецепт на сегодня'),
        content: SingleChildScrollView(child: Text(advice)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ОК'))],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  /// ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final dates = _buildWindowDates();
    final df = DateFormat('dd MMM');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя цель'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Совет ИИ на сегодня',
            onPressed: _onGetAdvice,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar strip
            SizedBox(
              height: 90,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, idx) {
                        final d = dates[idx];
                        final w = _getWeightForDate(d);
                        return GestureDetector(
                          onTap: () {
                            // optionally show details for this day
                            final text = w != null ? 'Вес: ${w.toStringAsFixed(1)} кг' : 'Нет данных';
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${df.format(d)} — $text')));
                          },
                          child: Container(
                            width: 72,
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isSameDay(d, DateTime.now()) ? Colors.orange.shade100 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat('E').format(d), style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(DateFormat('d').format(d), style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(w != null ? '${w.toStringAsFixed(1)}kg' : '-', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // small sparkline under calendar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: _buildSparkline(),
                  ),
                ],
              ),
            ),

            // Goal editor
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(children: const [Text('Установка цели', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<GoalType>(
                          value: _goal.type,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: GoalType.loseWeight, child: Text('Похудеть')),
                            DropdownMenuItem(value: GoalType.gainWeight, child: Text('Набрать вес')),
                            DropdownMenuItem(value: GoalType.maintain, child: Text('Поддерживать вес')),
                            DropdownMenuItem(value: GoalType.nutrientFocus, child: Text('Улучшить микроэлементы')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _goal.type = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Целевой вес (кг)', hintText: 'e.g. 70.0'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTargetDate = picked;
                              _goal.targetDate = picked;
                            });
                          }
                        },
                        child: Text(_selectedTargetDate == null ? 'Выбрать дату' : DateFormat('dd MMM yyyy').format(_selectedTargetDate!)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Nutrient chips
                  Wrap(
                    spacing: 8,
                    children: ['Protein', 'Fat', 'Carbs', 'Calcium', 'Vitamin D', 'Iron']
                        .map((n) => FilterChip(
                      label: Text(n),
                      selected: _goal.nutrients.contains(n),
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _goal.nutrients = [..._goal.nutrients, n];
                          } else {
                            _goal.nutrients = _goal.nutrients.where((x) => x != n).toList();
                          }
                        });
                      },
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(onPressed: _saveGoal, icon: const Icon(Icons.save), label: const Text('Сохранить цель')),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(onPressed: _addProgressEntry, icon: const Icon(Icons.add), label: const Text('Добавить запись прогресса')),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Chat + AI advice area
            Expanded(
              child: Column(
                children: [
                  // Quick AI suggestion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(child: Text('Совет от ИИ', style: Theme.of(context).textTheme.subtitle1)),
                        TextButton.icon(onPressed: _onGetAdvice, icon: const Icon(Icons.lightbulb_outline), label: const Text('Получить')),
                      ],
                    ),
                  ),

                  // Chat log
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _chat.length,
                        itemBuilder: (context, index) {
                          final item = _chat[_chat.length - 1 - index];
                          final isAi = item['role'] == 'ai';
                          return Align(
                            alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 320),
                              decoration: BoxDecoration(
                                color: isAi ? Colors.grey.shade200 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(item['text'] ?? ''),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Input
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: const InputDecoration(hintText: 'Спросить ИИ: Как приготовить...'),
                              onSubmitted: (_) => _onSendChat(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: _onSendChat, child: const Text('Отправить')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple sparkline painter used in the screen.
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintAxis = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final double w = size.width;
    final double h = size.height;
    canvas.drawLine(Offset(0, h - 1), Offset(w, h - 1), paintAxis);

    // normalize only numeric values
    final numeric = values.where((v) => v.isFinite).toList();
    if (numeric.isEmpty) return;

    double minV = numeric.reduce((a, b) => a < b ? a : b);
    double maxV = numeric.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) {
      minV -= 1;
      maxV += 1;
    }

    final stepX = w / (values.length - 1).clamp(1, double.infinity);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      final x = stepX * i;
      if (!v.isFinite) {
        // skip — move to next
        continue;
      }
      final t = (v - minV) / (maxV - minV);
      final y = h - t * (h - 8) - 4;
      if (path.isEmpty) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
