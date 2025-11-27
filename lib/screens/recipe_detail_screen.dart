// lib/screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/user_recipe.dart';
import '../services/ai_service.dart';
import 'dart:async';

class RecipeDetailScreen extends StatefulWidget {
  final UserRecipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Можно добавить приветственное сообщение от ИИ
    _messages.add(_ChatMessage(
      text: 'Привет! Я помощник по рецепту "${widget.recipe.title}". Спроси меня, например: как сократить время готовки или чем заменить ингредиент.',
      isBot: true,
    ));
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
      _sending = true;
      _controller.clear();
    });

    try {
      final answer = await AIService.askRecipeQuestion(
          recipe: widget.recipe, question: text);
      setState(() {
        _messages.add(_ChatMessage(text: answer, isBot: true));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(text: 'Ошибка: $e', isBot: true));
      });
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMessage(_ChatMessage m) {
    final alignment = m.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final color = m.isBot ? Colors.grey.shade200 : Colors.blue.shade200;
    final radius = m.isBot
        ? const BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
        : const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12));

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color, borderRadius: radius),
          child: Text(m.text),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final imageUrl = r.imageUrl.isNotEmpty
        ? r.imageUrl
        : "https://source.unsplash.com/featured/?${Uri.encodeComponent(r.title)}";

    return Scaffold(
      appBar: AppBar(title: Text(r.title)),
      body: SafeArea(
        child: Column(
          children: [
            // image + title block
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(height:200, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.fastfood))),),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(r.description),
                const SizedBox(height: 8),
                Text('Ингредиенты: ${r.ingredients.join(", ")}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
              ]),
            ),

            const Divider(),
            // chat area (expanded)
            Expanded(
              child: ListView.builder(
                reverse: false,
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  return _buildMessage(_messages[i]);
                },
              ),
            ),

            if (_sending) const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            ),

            // input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Задать вопрос по рецепту...',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sending ? null : _send,
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

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage({required this.text, required this.isBot});
}
