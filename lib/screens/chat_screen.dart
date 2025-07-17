import 'package:flutter/material.dart';
import 'package:my_app/config.dart';
import 'package:my_app/services/chat_service.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/user_message.dart';
import '../models/server_message.dart'; // ⬅️ не забываем!
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _uuid = const Uuid();
  final List<ChatSession> _sessions = [];
  String _activeSessionId = '';
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _createNewSession();

    _chatService = ChatService(AppConfig.websocketUrl);

_chatService.onConnected = () => print('WebSocket connected');
_chatService.onDisconnected = () => print('WebSocket disconnected');
_chatService.onError = (e) => print('WebSocket error: $e');


    _chatService.messages.listen((serverMessage) {
      final session = _sessions.firstWhere((s) => s.id == _activeSessionId);
      final chatMessage = ChatMessage.fromServer(serverMessage);

      setState(() {
        session.messages.add(chatMessage);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

  }

  void _createNewSession() {
    final id = _uuid.v4();
    setState(() {
      _sessions.add(ChatSession(
        id: id,
        title: 'Чат ${_sessions.length + 1}',
      ));
      _activeSessionId = id;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onSessionSelected(String sessionId) {
    if (sessionId.isEmpty) {
      _createNewSession();
    } else {
      setState(() => _activeSessionId = sessionId);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend(UserMessage userMsg) {
  final session = _sessions.firstWhere((s) => s.id == _activeSessionId);

  setState(() {
    session.messages.add(ChatMessage.fromUser(userMsg));
  });

  _chatService.sendUserMessage(userMsg);
}


  @override
  void dispose() {
    _chatService.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSession =
        _sessions.firstWhere((s) => s.id == _activeSessionId);

    return Scaffold(
      drawer: ChatSidebar(
        sessions: _sessions,
        activeSessionId: _activeSessionId,
        onSessionSelected: _onSessionSelected,
      ),
      appBar: AppBar(
        title: Text(activeSession.title),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: activeSession.messages.length,
              itemBuilder: (_, i) => ChatBubble(
                message: activeSession.messages[i],
              ),
            ),
          ),
     ChatInput(
  controller: _textController,
  onSend: _handleSend, // где ты уже обрабатываешь UserMessage
),
        ],
      ),
    );
  }
}
