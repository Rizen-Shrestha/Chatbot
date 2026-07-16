import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getChatHistory(String uid);
  Stream<String> sendMessageAndStreamAIResponse(String uid, String messageText);
}