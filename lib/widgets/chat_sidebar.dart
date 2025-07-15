// lib/widgets/chat_sidebar.dart
import 'package:flutter/material.dart';
import '../models/chat_session.dart';

class ChatSidebar extends StatelessWidget {
  final List<ChatSession> sessions;
  final String activeSessionId;
  final ValueChanged<String> onSessionSelected;

  const ChatSidebar({
    super.key,
    required this.sessions,
    required this.activeSessionId,
    required this.onSessionSelected,
  });

  void _selectAndClose(BuildContext context, String sessionId) {
    onSessionSelected(sessionId);
    Navigator.of(context).pop(); // Закрыть drawer
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Drawer уже сам задаёт ширину и фон
      child: Column(
        children: [
          const SizedBox(height: 56, child: DrawerHeader(child: Text('Чаты'))),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Новый чат'),
            onTap: () => _selectAndClose(context, ''),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text(session.title),
                  selected: session.id == activeSessionId,
                  onTap: () => _selectAndClose(context, session.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
