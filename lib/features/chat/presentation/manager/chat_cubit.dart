import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;

  StreamSubscription? _historySubscription;
  List<ChatMessage> _cachedMessages = [];

  ChatCubit({
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatInitial());

  void listenToMessages(String uid) {
    _historySubscription?.cancel();
    _historySubscription = getChatHistoryUseCase(uid).listen((messages) {
      _cachedMessages = messages;
      emit(ChatHistoryLoaded(_cachedMessages));
    }, onError: (err) => emit(ChatFailure(err.toString())));
  }

  Future<void> sendChatMessage(String uid, String messageText) async {
    if (messageText.trim().isEmpty) return;

    String temporaryChunk = "";

    // Inject streaming response listener
    sendMessageUseCase(uid, messageText).listen(
      (chunk) {
        temporaryChunk += chunk;
        emit(
          ChatHistoryLoaded(
            _cachedMessages,
            activeStreamingChunk: temporaryChunk,
          ),
        );
      },
      onDone: () {
        // Clear streaming cache layer once written completely to DB
        emit(ChatHistoryLoaded(_cachedMessages, activeStreamingChunk: ""));
      },
      onError: (err) => emit(ChatFailure(err.toString())),
    );
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}
