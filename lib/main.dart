import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = await ThemeService.create();

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const ChatGPTApp(),
    ),
  );
}

class ChatGPTApp extends StatelessWidget {
  const ChatGPTApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (themeService.useDynamicColor && lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = ColorScheme.fromSeed(
            seedColor: themeService.themeColor,
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: themeService.themeColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'ChatGPT',
          themeMode: themeService.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            brightness: Brightness.dark,
          ),
          home: FutureBuilder<String>(
            future: _getInitialSession(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ChatScreen(sessionId: snapshot.data!);
            },
          ),
        );
      },
    );
  }

  Future<String> _getInitialSession() async {
    final chatService = ChatService();
    final sessions = await chatService.getAllSessions();
    if (sessions.isEmpty) {
      final session = await chatService.createSession();
      return session.id;
    }
    return sessions.first.id;
  }
}