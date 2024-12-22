import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatService _chatService = ChatService();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedSessions = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _chatService.getAllSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sessions: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewSession() async {
    final session = await _chatService.createSession();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(sessionId: session.id),
      ),
    ).then((_) => _loadSessions());
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedSessions.clear();
      }
    });
  }

  void _toggleSessionSelection(String sessionId) {
    setState(() {
      if (_selectedSessions.contains(sessionId)) {
        _selectedSessions.remove(sessionId);
      } else {
        _selectedSessions.add(sessionId);
      }

      if (_selectedSessions.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  Future<void> _deleteSelectedSessions() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除对话'),
        content: Text('确定要删除选中的 ${_selectedSessions.length} 个对话吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isLoading = true);

      for (final sessionId in _selectedSessions) {
        await _chatService.deleteSession(sessionId);
      }

      _selectedSessions.clear();
      _isSelectionMode = false;
      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleSelectionMode,
        )
            : null,
        title: _isSelectionMode
            ? Text('已选择 ${_selectedSessions.length} 项')
            : const Text('聊天记录'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedSessions.isNotEmpty ? _deleteSelectedSessions : null,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectionMode,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createNewSession,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return ListTile(
            leading: _isSelectionMode
                ? Checkbox(
              value: _selectedSessions.contains(session.id),
              onChanged: (_) => _toggleSessionSelection(session.id),
            )
                : const Icon(Icons.chat_bubble_outline),
            title: Text(session.title),
            subtitle: Text(
              '${session.messages.length}条消息 · ${_formatDate(session.createdAt)}',
            ),
            onTap: _isSelectionMode
                ? () => _toggleSessionSelection(session.id)
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(sessionId: session.id),
                ),
              ).then((_) => _loadSessions());
            },
            onLongPress: !_isSelectionMode
                ? () {
              _toggleSelectionMode();
              _toggleSessionSelection(session.id);
            }
                : null,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 