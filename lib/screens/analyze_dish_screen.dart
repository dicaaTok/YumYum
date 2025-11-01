import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AnalyzeDishScreen extends StatefulWidget {
  const AnalyzeDishScreen({super.key});

  @override
  State<AnalyzeDishScreen> createState() => _AnalyzeDishScreenState();
}

class _AnalyzeDishScreenState extends State<AnalyzeDishScreen> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _result;
  bool _loading = false;

  Future<void> _analyze() async {
    if (_controller.text.isEmpty) return;
    setState(() => _loading = true);

    final result = await AIService.analyzeDish(_controller.text);

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Анализ блюда')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Введите название или описание блюда',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _analyze,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Анализировать'),
            ),
            const SizedBox(height: 20),
            if (_result != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Калории: ${_result!['calories']}'),
                        Text('Белки: ${_result!['proteins']}'),
                        Text('Жиры: ${_result!['fats']}'),
                        Text('Углеводы: ${_result!['carbs']}'),
                        Text('Оценка полезности: ${_result!['healthScore']} / 10'),
                        const SizedBox(height: 8),
                        Text('Совет: ${_result!['advice']}'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
