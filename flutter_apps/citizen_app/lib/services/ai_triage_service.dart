import 'package:google_generative_ai/google_generative_ai.dart';

class AiTriageService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with actual key or use env variables
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _useFallback = false;

  // Fallback state
  int _fallbackStep = 0;

  AiTriageService() {
    _initModel();
  }

  void _initModel() {
    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      _useFallback = true;
      return;
    }
    
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system('''
You are an emergency first aid AI assistant. A bystander has found an accident victim. Guide them step by step through basic first aid. Be calm, clear, and concise. Each response should be 2-3 sentences max. Ask one question at a time. Start by asking if the person is breathing. Respond in the language the user speaks. Always prioritize: 1. Airway 2. Breathing 3. Circulation 4. Disability/consciousness.
'''),
      );
    } catch (e) {
      _useFallback = true;
    }
  }

  Future<void> initChat() async {
    if (_useFallback || _model == null) {
      _fallbackStep = 0;
      return;
    }
    _chatSession = _model!.startChat();
  }

  String getInitialQuestion(String language) {
    if (language.toLowerCase() == 'gujarati') {
      return "શું વ્યક્તિ શ્વાસ લઈ રહી છે?";
    } else if (language.toLowerCase() == 'hindi') {
      return "क्या व्यक्ति सांस ले रहा है?";
    }
    return "Is the person breathing?";
  }

  Future<String> sendMessage(String userMessage) async {
    if (_useFallback || _chatSession == null) {
      return _getFallbackResponse(userMessage);
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(userMessage));
      return response.text ?? "I'm sorry, I couldn't process that. Please tell me if they are breathing.";
    } catch (e) {
      _useFallback = true; // Switch to fallback on error
      return _getFallbackResponse(userMessage);
    }
  }

  String _getFallbackResponse(String input) {
    input = input.toLowerCase();
    bool isYes = input.contains('yes') || input.contains('હા') || input.contains('हां') || input.contains('ha');
    
    switch (_fallbackStep) {
      case 0:
        _fallbackStep++;
        if (isYes) {
          return "Great. Do they have a pulse? Check the side of their neck.";
        } else {
          return "Call emergency services immediately. Start CPR. Push hard and fast in the center of the chest.";
        }
      case 1:
        _fallbackStep++;
        if (isYes) {
          return "Are they bleeding severely anywhere?";
        } else {
          return "Start CPR immediately. Push hard and fast in the center of the chest. Continue until help arrives.";
        }
      case 2:
        _fallbackStep++;
        if (isYes) {
          return "Apply firm, direct pressure to the bleeding wound with a clean cloth. Are they conscious?";
        } else {
          return "Keep them warm and still. Are they conscious?";
        }
      default:
        return "Please wait for emergency services to arrive. Do not move the person unless they are in immediate danger.";
    }
  }
}
