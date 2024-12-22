import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/feedback_wrapper.dart';
import 'author_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        children: [
          _buildAppInfo(context),
          const Divider(height: 1),
          FeedbackWrapper(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthorScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('作者'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const Divider(height: 1),
          _buildDependencies(context),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final info = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.android,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ChatGPT',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '版本 ${info.version}+${info.buildNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDependencies(BuildContext context) {
    final dependencies = [
      '动态取色 - dynamic_color',
      '路径管理 - path_provider',
      '状态管理 - provider',
      '持久化存储 - shared_preferences',
      '包信息 - package_info_plus',
      'URL处理 - url_launcher',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '开源依赖',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...dependencies.map((dep) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(dep),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}