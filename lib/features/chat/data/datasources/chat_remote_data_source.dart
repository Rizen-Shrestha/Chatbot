import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  // 1. Defined so the repository can fetch old messages
  Stream<List<ChatModel>> getChatHistory(String uid);

  // 2. Renamed to match what ChatRepositoryImpl calls
  Stream<String> sendAndStreamAI(String uid, String messageText);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ChatModel>> getChatHistory(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<String> sendAndStreamAI(String uid, String messageText) async* {
    // 1. Save user's prompt to Firestore history first
    final userMessageRef = firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .doc();

    await userMessageRef.set({
      'text': messageText,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Retrieve user preferences from the database to build our personalized persona
    final userDoc = await firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};
    final List<String> interests = List<String>.from(userData['interests'] ?? []);

    // Create a personalized instruction prompt based on Onboarding choices
    String systemInstructions = "You are a helpful, empathetic, and encouraging personal AI companion.";
    if (interests.isNotEmpty) {
      systemInstructions += " The user has specified the following target focus areas: ${interests.join(', ')}."
          " Act as a specialized coach in these domains and tailor your insights to help them succeed here.";
    }

    // 3. Initialize the Gemini Model securely using Environment Variables
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      yield "Error: Gemini API key is missing. Please check your compilation flags.";
      return;
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstructions),
    );

    // 4. Build Chat History Context (fetch last 10 messages for conversational context)
    final historySnapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    final List<Content> chatSessionContents = [];
    final reversedDocs = historySnapshot.docs.reversed.toList();

    for (var doc in reversedDocs) {
      final data = doc.data();
      final text = data['text'] as String? ?? '';
      final isUser = data['sender'] == 'user';

      if (text.isNotEmpty) {
        chatSessionContents.add(
          isUser ? Content.text(text) : Content.model([TextPart(text)]),
        );
      }
    }

    // Append the newly sent message to the active payload session
    chatSessionContents.add(Content.text(messageText));

    // 5. Generate and Stream the response chunks
    final responseStream = model.generateContentStream(chatSessionContents);
    String fullModelResponse = "";

    await for (final chunk in responseStream) {
      final chunkText = chunk.text ?? "";
      if (chunkText.isNotEmpty) {
        fullModelResponse += chunkText;
        yield chunkText; // Sends text fragments instantly to your UI layer
      }
    }

    // 6. Save the AI's fully synthesized response back to Firestore history
    await firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .add({
      'text': fullModelResponse,
      'sender': 'ai',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}