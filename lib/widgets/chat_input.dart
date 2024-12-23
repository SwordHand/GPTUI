import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_model_service.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const ChatInput({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Consumer<AIModelService>(
              builder: (context, service, _) {
                final model = service.selectedModel;
                return IconButton(
                  icon: Image.asset(
                    model?.logo ?? service.models.first.logo,
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () => _showModelSelector(context, service),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8.0),
            FloatingActionButton(
              onPressed: _sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelSelector(BuildContext context, AIModelService service) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 200, // 向上弹出
        offset.dx + button.size.width,
        offset.dy,
      ),
      items: service.enabledModels.map((model) {
        return PopupMenuItem<String>(
          value: model.id,
          child: Row(
            children: [
              Image.asset(
                model.logo,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(model.name)),
              if (model.id == service.selectedModel?.id)
                const Icon(Icons.check),
            ],
          ),
        );
      }).toList(),
    ).then((modelId) {
      if (modelId != null) {
        service.setSelectedModel(modelId);
      }
    });
  }
} 