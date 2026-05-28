import 'package:firebase_ai/firebase_ai.dart';

const _systemPrompt = '''
Eres "Tupac", el asistente de IA de Artesanías Andinas, una app que
conecta artesanos cusqueños con compradores de todo el mundo.

TU ESPECIALIDAD:
- Experto en artesanías andinas: cerámica, textiles, joyería, retablos,
mates burilados, tallado en piedra, orfebrería y más.
- Conoces las técnicas tradicionales del Cusco, Puno y Ayacucho.
- Puedes ayudar a compradores a elegir regalos según presupuesto y gusto.
- Puedes explicar el valor cultural detrás de cada pieza artesanal.

TUS REGLAS:
- Responde siempre en el idioma del usuario.
- Máximo 3 párrafos por respuesta; más detalle solo si se pide.
- No inventes precios exactos; usa rangos aproximados.
- Si no sabes algo, dilo con honestidad.
- Nunca te salgas del tema de artesanías andinas y cultura cusqueña.
- Tono: amigable, culto y respetuoso de la cosmovisión andina.
''';

abstract class GeminiDataSource {
  Stream<String> sendMessageStreaming({
    required String message,
    String? productContext,
  });

  Future<String> sendMessage({
    required String message,
    String? productContext,
  });

  void resetSession();
}

class GeminiDataSourceImpl implements GeminiDataSource {
  late final GenerativeModel _model;
  late ChatSession _chat;

  GeminiDataSourceImpl() {
    final firebaseAI = FirebaseAI.googleAI();

    _model = firebaseAI.generativeModel(
      model: 'gemini-3.5-flash',
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );

    _chat = _model.startChat();
  }

  @override
  Stream<String> sendMessageStreaming({
    required String message,
    String? productContext,
  }) async* {
    final fullMessage = productContext != null && productContext.isNotEmpty
        ? 'Contexto del producto:\n$productContext\n\nPregunta del usuario:\n$message'
        : message;

    final responseStream = _chat.sendMessageStream(
      Content.text(fullMessage),
    );

    await for (final chunk in responseStream) {
      final text = chunk.text;

      if (text != null && text.isNotEmpty) {
        yield text;
      }
    }
  }

  @override
  Future<String> sendMessage({
    required String message,
    String? productContext,
  }) async {
    final fullMessage = productContext != null && productContext.isNotEmpty
        ? 'Contexto del producto:\n$productContext\n\nPregunta del usuario:\n$message'
        : message;

    final response = await _chat.sendMessage(
      Content.text(fullMessage),
    );

    return response.text ?? '';
  }

  @override
  void resetSession() {
    _chat = _model.startChat();
  }
}
