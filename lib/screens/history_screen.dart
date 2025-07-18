import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import 'chat_screen.dart'; // сейчас ChatScreen не принимает sessionId

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<ChatSession> _sessions = [];

  void _openSession() {
    // просто открываем ChatScreen — он сам создаст новую сессию
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _newSession() => _openSession();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История чатов')),
      body: _sessions.isEmpty
          ? const Center(child: Text('Нет сохранённых чатов'))
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, i) {
                final s = _sessions[i];
                return ListTile(title: Text(s.title), onTap: _openSession);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newSession,
        tooltip: 'Новый чат',
        child: const Icon(Icons.add),
      ),
    );
  }
}
