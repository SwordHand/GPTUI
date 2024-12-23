import 'package:flutter/material.dart';
import '../widgets/chat_message.dart';
import '../widgets/chat_input.dart';
import '../components/app_drawer.dart';
import '../models/chat_session.dart';
import '../services/chat_service.dart';
import '../screens/chat_history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/author_screen.dart';
import '../screens/about_screen.dart';
import 'dart:io';
import '../services/wallpaper_service.dart';
import 'package:provider/provider.dart';
import '../screens/ai_models_screen.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;

  const ChatScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  late ChatSession _session;
  bool _isLoading = true;
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final session = await _chatService.getSession(widget.sessionId);
      setState(() {
        _session = session;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading session: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendMessage(String text) async {
    final message = ChatMessageModel(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _session.messages.add(message);
    });

    // 模拟AI回复
    final aiMessage = ChatMessageModel(
      text: '这是一个模拟的AI回复消息。',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _session.messages.add(aiMessage);
    });

    // 保存会话
    await _chatService.saveSession(_session);

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _editTitle() async {
    final TextEditingController titleController = TextEditingController(
      text: _session.title,
    );

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑标题'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '对话标题',
            hintText: '输入新的标题',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != _session.title) {
      await _chatService.updateSessionTitle(widget.sessionId, newTitle);
      await _loadSession();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _getWallpaperPath() async {
    final wallpaperService = context.read<WallpaperService>();
    final selectedWallpaper = wallpaperService.selectedWallpaper;
    if (selectedWallpaper == null) return null;

    if (selectedWallpaper.startsWith('bg')) {
      return 'assets/wallpapers/$selectedWallpaper';
    }

    return await wallpaperService.getWallpaperPath(selectedWallpaper);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _editTitle,
          child: Row(
            children: [
              Expanded(
                child: Text(_session.title),
              ),
              const Icon(
                Icons.edit,
                size: 16,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final session = await _chatService.createSession();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(sessionId: session.id),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedDrawerIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedDrawerIndex = index;
          });
          Navigator.pop(context);

          switch (index) {
            case 0: // 聊天
              break;
            case 1: // 历史记录
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
              break;
            case 2: // AI 模型
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIModelsScreen(),
                ),
              );
              break;
            case 3: // 作者
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthorScreen(),
                ),
              );
              break;
            case 4: // 设置
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              break;
            case 5: // 关于
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
              break;
          }
        },
      ),
      body: Stack(
        children: [
          // 背景
          Consumer<WallpaperService>(
            builder: (context, wallpaperService, _) {
              return FutureBuilder<String?>(
                future: _getWallpaperPath(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox();
                  }

                  final path = snapshot.data!;
                  if (path.startsWith('assets/')) {
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }

                  return Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              );
            },
          ),
          // 聊天内容
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    8.0,
                    8.0,
                    8.0,
                    MediaQuery.of(context).padding.bottom + 80.0,
                  ),
                  itemCount: _session.messages.length,
                  itemBuilder: (context, index) {
                    final message = _session.messages[index];
                    return ChatMessage(
                      text: message.text,
                      isUser: message.isUser,
                    );
                  },
                ),
              ),
              ChatInput(onSendMessage: _handleSendMessage),
            ],
          ),
        ],
      ),
    );
  }
}