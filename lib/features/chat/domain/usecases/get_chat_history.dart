import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;
  GetChatHistoryUseCase(this.repository);

  Stream<List<ChatMessage>> call(String uid) => repository.getChatHistory(uid);
}