import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatMessage>> getChatHistory(String uid) =>
      remoteDataSource.getChatHistory(uid);

  @override
  Stream<String> sendMessageAndStreamAIResponse(
    String uid,
    String messageText,
  ) {
    return remoteDataSource.sendAndStreamAI(uid, messageText);
  }
}
