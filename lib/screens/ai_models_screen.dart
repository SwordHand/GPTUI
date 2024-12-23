import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_model_service.dart';
import '../models/ai_model.dart';
import '../utils/feedback_wrapper.dart';

class AIModelsScreen extends StatelessWidget {
  const AIModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 模型'),
      ),
      body: Consumer<AIModelService>(
        builder: (context, service, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: service.models.length,
            itemBuilder: (context, index) {
              final model = service.models[index];
              return _buildModelCard(context, model);
            },
          );
        },
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, AIModel model) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: _ModelExpandableCard(model: model),
    );
  }
}

class _ModelExpandableCard extends StatefulWidget {
  final AIModel model;

  const _ModelExpandableCard({required this.model});

  @override
  State<_ModelExpandableCard> createState() => _ModelExpandableCardState();
}

class _ModelExpandableCardState extends State<_ModelExpandableCard> {
  bool _isExpanded = false;
  late TextEditingController _urlController;
  late TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.model.customUrl ?? widget.model.defaultUrl);
    _keyController = TextEditingController(text: widget.model.apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Image.asset(
            widget.model.logo,
            width: 40,
            height: 40,
          ),
          title: Text(widget.model.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: widget.model.enabled,
                onChanged: (value) {
                  final service = context.read<AIModelService>();
                  widget.model.enabled = value;
                  service.saveModel(widget.model);
                },
              ),
              IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'API URL',
                    hintText: '输入模型请求地址',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: '输入模型密钥',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final service = context.read<AIModelService>();
                    widget.model.customUrl = _urlController.text;
                    widget.model.apiKey = _keyController.text;
                    service.saveModel(widget.model);
                  },
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }
}