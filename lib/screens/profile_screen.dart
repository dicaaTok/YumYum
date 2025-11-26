import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("⚙️ Профиль"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.orange.shade100,
              child: const Icon(Icons.person, size: 70),
            ),

            const SizedBox(height: 20),
            const Text(
              "Гость",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),
            _ProfileItem(Icons.book, "Мои рецепты"),
            _ProfileItem(Icons.star, "Избранное"),
            _ProfileItem(Icons.dark_mode, "Тёмная тема"),
            _ProfileItem(Icons.logout, "Выйти"),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileItem(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 14),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
