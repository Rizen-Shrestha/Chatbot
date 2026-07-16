import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Stream<String> call(String uid, String messageText) {
    return repository.sendMessageAndStreamAIResponse(uid, messageText);
  }
}