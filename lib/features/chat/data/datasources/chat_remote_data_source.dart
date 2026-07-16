import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> getChatHistory(String uid);

  Stream<String> sendAndStreamAI(String uid, String messageText);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  // NOTE: Insert your real Gemini API key here or source from environment variables safely.
  static const _apiKey = "YOUR_GEMINI_API_KEY";

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ChatModel>> getChatHistory(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<String> sendAndStreamAI(String uid, String messageText) async* {
    final userMsgRef = firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .doc();

    // 1. Immediately save User's incoming message to Firestore
    await userMsgRef.set({
      'text': messageText,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Query user preferences to engineer the dynamic persona system prompt
    final userDoc = await firestore.collection('users').doc(uid).get();
    final List<dynamic> interests = userDoc.data()?['interests'] ?? [];

    final systemInstruction =
        '''
    You are an AI life assistant. The user has explicitly selected these core life interests: ${interests.join(', ')}. 
    Tailor your responses specifically through these lenses. If a user asks a general question, skew the analogy, context, advice, or layout to serve these interests natively. Keep answers actionable, engaging, and dynamic.
    ''';

    // 3. Initialize Gemini with strict instructions
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    // 4. Gather recent conversation context for chat history injection
    final pastMessagesSnapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limitToLast(10)
        .get();

    final List<Content> contentHistory = pastMessagesSnapshot.docs.map((doc) {
      final role = doc.data()['sender'] == 'user' ? 'user' : 'model';
      return Content(role, [TextPart(doc.data()['text'] ?? '')]);
    }).toList();

    // 5. Send stream request to the AI cluster
    final responseStream = model.generateContentStream(contentHistory);

    String fullResponseAccumulator = "";
    final aiMsgRef = firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .doc();

    await for (final chunk in responseStream) {
      if (chunk.text != null) {
        fullResponseAccumulator += chunk.text!;
        yield chunk.text!;
      }
    }

    // 6. Complete transaction by logging full AI output inside history records
    await aiMsgRef.set({
      'text': fullResponseAccumulator,
      'sender': 'ai',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
