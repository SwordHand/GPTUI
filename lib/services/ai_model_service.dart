import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ai_model.dart';

class AIModelService extends ChangeNotifier {
  static const String _modelsDir = 'models';
  final List<AIModel> _defaultModels = [
    AIModel(
      id: 'gpt-4',
      name: 'GPT-4',
      logo: 'assets/images/gpt.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
      enabled: true,
    ),
    AIModel(
      id: 'gpt-4o',
      name: 'GPT-4o',
      logo: 'assets/images/gpt.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'gpt-4o-mini',
      name: 'GPT-4o-mini',
      logo: 'assets/images/gpt.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'gpt-4o1',
      name: 'GPT-4o1',
      logo: 'assets/images/gpt.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'gpt-4o1-pro',
      name: 'GPT-4o1-pro',
      logo: 'assets/images/gpt.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'gemini-1.5',
      name: 'gemini-1.5',
      logo: 'assets/images/gemini.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'gemini-1.5-flash',
      name: 'gemini-1.5-flash',
      logo: 'assets/images/gemini.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'gemini-2.0',
      name: 'gemini-2.0',
      logo: 'assets/images/gemini.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'meta-llama/Llama-3.1-8B-Instruct',
      name: 'Llama-3.1-8B-Instruct',
      logo: 'assets/images/meta-llama.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'meta-llama/Llama-3.2-3B-Instruct',
      name: 'Llama-3.2-3B-Instruct',
      logo: 'assets/images/meta-llama.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'meta-llama/Llama-3.3-70B-Instruct',
      name: 'Llama-3.3-70B-Instruct',
      logo: 'assets/images/meta-llama.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'meta-llama/Meta-Llama-3-8B-Instruct',
      name: 'Llama-3-8B-Instruct',
      logo: 'assets/images/meta-llama.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'meta-llama/Llama-3.2-1B-Instruct',
      name: 'Llama-3.2-1B-Instruct',
      logo: 'assets/images/meta-llama.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'meta-llama/Llama-3.1-70B-Instruct',
      name: 'Llama-3.1-70B-Instruct',
      logo: 'assets/images/meta-llama.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Qwen2.5-72B-Instruct',
      name: 'Qwen-2.5-72B-Instruct',
      logo: 'assets/images/Qwen.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'QwQ-32B-Preview',
      name: 'QwQ-32B-Preview',
      logo: 'assets/images/Qwen.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Qwen-2.5-Coder-32B-Instruct',
      name: 'Qwen-2.5-Coder-32B-Instruct',
      logo: 'assets/images/Qwen.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Qwen-2.5-Coder-1.5B-Instruct',
      name: 'Qwen-2.5-Coder-1.5B-Instruct',
      logo: 'assets/images/Qwen.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),

    AIModel(
      id: 'microsoft-DialoGPT-large',
      name: 'DialoGPT-large',
      logo: 'assets/images/microsoft.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'microsoft/DialoGPT-medium',
      name: 'DialoGPT-medium',
      logo: 'assets/images/microsoft.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'microsoft/Phi-3-mini-4k-instruct',
      name: 'Phi-3-mini-4k-instruct',
      logo: 'assets/images/microsoft.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'microsoft/Phi-3.5-mini-instruct',
      name: 'Phi-3.5-mini-instruct',
      logo: 'assets/images/microsoft.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Mistral-7B-Instruct-v0.2',
      name: 'Mistral-7B-Instruct-v0.2',
      logo: 'assets/images/mistralai.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Mistral-7B-Instruct-v0.3',
      name: 'Mistral-7B-Instruct-v0.3',
      logo: 'assets/images/mistralai.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Mistral-Nemo-Instruct-2407',
      name: 'Mistral-Nemo-Instruct-2407',
      logo: 'assets/images/mistralai.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),
    AIModel(
      id: 'Mixtral-8x7B-Instruct-v0.1',
      name: 'Mixtral-8x7B-Instruct-v0.1',
      logo: 'assets/images/mistralai.png',
      defaultUrl: 'https://api.openai.com/v1/chat/completions',
    ),


    // 添加更多默认模型...
  ];

  List<AIModel> _models = [];
  String? _selectedModelId;

  AIModelService() {
    _models = List.from(_defaultModels);
    _selectedModelId = _models.first.id;
  }

  List<AIModel> get models => _models;
  List<AIModel> get enabledModels => _models.where((m) => m.enabled).toList();
  AIModel? get selectedModel => _models.firstWhere(
        (m) => m.id == _selectedModelId,
    orElse: () => _models.firstWhere((m) => m.enabled, orElse: () => _models.first),
  );

  Future<void> loadModels() async {
    final directory = await _getModelsDirectory();

    for (final model in _models) {
      final file = File('${directory.path}/${model.id}.json');
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString());
        final index = _models.indexWhere((m) => m.id == model.id);
        _models[index] = AIModel.fromJson(json, model);
      }
    }

    notifyListeners();
  }

  Future<void> saveModel(AIModel model) async {
    final directory = await _getModelsDirectory();
    final file = File('${directory.path}/${model.id}.json');
    await file.writeAsString(jsonEncode(model.toJson()));

    final index = _models.indexWhere((m) => m.id == model.id);
    if (index != -1) {
      _models[index] = model;
    }

    notifyListeners();
  }

  Future<void> setSelectedModel(String modelId) async {
    _selectedModelId = modelId;
    notifyListeners();
  }

  Future<Directory> _getModelsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${directory.path}/$_modelsDir');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }
}