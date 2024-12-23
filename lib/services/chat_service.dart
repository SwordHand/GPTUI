import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/chat_session.dart';

class ChatService {
  static const String _sessionsDir = 'chat_sessions';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final sessionPath = '${directory.path}/$_sessionsDir';
    await Directory(sessionPath).create(recursive: true);
    return sessionPath;
  }

  Future<File> _getSessionFile(String sessionId) async {
    final path = await _localPath;
    return File('$path/$sessionId.json');
  }

  Future<List<ChatSession>> getAllSessions() async {
    final path = await _localPath;
    final dir = Directory(path);
    final List<ChatSession> sessions = [];

    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>().where(
            (file) => file.path.endsWith('.json'),
      );

      for (final file in files) {
        try {
          final content = await file.readAsString();
          final session = ChatSession.fromJson(json.decode(content));
          sessions.add(session);
        } catch (e) {
          print('Error reading session file: $e');
        }
      }
    }

    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  Future<int> _getNextSessionNumber() async {
    final sessions = await getAllSessions();
    if (sessions.isEmpty) return 1;

    final numberPattern = RegExp(r'对话(\d+)');
    int maxNumber = 0;

    for (final session in sessions) {
      final match = numberPattern.firstMatch(session.title);
      if (match != null) {
        final number = int.parse(match.group(1)!);
        if (number > maxNumber) maxNumber = number;
      }
    }

    return maxNumber + 1;
  }

  Future<ChatSession> createSession({bool isFirst = false}) async {
    final nextNumber = isFirst ? 1 : await _getNextSessionNumber();
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '对话$nextNumber',
      createdAt: DateTime.now(),
      messages: [],
    );
    await saveSession(session);
    return session;
  }

  Future<ChatSession> getSession(String sessionId) async {
    final file = await _getSessionFile(sessionId);
    final content = await file.readAsString();
    return ChatSession.fromJson(json.decode(content));
  }

  Future<void> saveSession(ChatSession session) async {
    final file = await _getSessionFile(session.id);
    await file.writeAsString(json.encode(session.toJson()));
  }

  Future<void> deleteSession(String sessionId) async {
    final file = await _getSessionFile(sessionId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final session = await getSession(sessionId);
    final updatedSession = ChatSession(
      id: session.id,
      title: newTitle,
      createdAt: session.createdAt,
      messages: session.messages,
    );
    await saveSession(updatedSession);
  }
} 