import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/feedback_wrapper.dart';

class AuthorScreen extends StatelessWidget {
  const AuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作者'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAuthorCard(context),
          const SizedBox(height: 16),
          _buildContactCard(context),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(height: 16),
            Text(
              'SwordHand',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '无他',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          FeedbackWrapper(
            onTap: () => _launchUrl('https://github.com/SwordHand'),
            child: ListTile(
              leading: const Icon(Icons.code),
              title: const Text('GitHub'),
              subtitle: const Text('@SwordHand'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const Divider(height: 1),
          FeedbackWrapper(
            onTap: () => _launchUrl('mailto:8888888'),
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('邮箱'),
              subtitle: const Text('8888888'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}