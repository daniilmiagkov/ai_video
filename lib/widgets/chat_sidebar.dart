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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[100],
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Новый чат'),
            onTap: () => onSessionSelected(''),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (_, i) {
                final s = sessions[i];
                return ListTile(
                  title: Text(s.title),
                  selected: s.id == activeSessionId,
                  onTap: () => onSessionSelected(s.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
