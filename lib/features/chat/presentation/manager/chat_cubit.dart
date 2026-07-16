import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_state.dart';
import '../../../gamification/domain/usecases/award_points.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final AwardPointsUseCase awardPointsUseCase;

  StreamSubscription? _historySubscription;
  List<ChatMessage> _cachedMessages = [];

  ChatCubit({
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
    required this.awardPointsUseCase,
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
      onDone: () async {
        emit(ChatHistoryLoaded(_cachedMessages, activeStreamingChunk: ""));

        try {
          await awardPointsUseCase(uid);
        } catch (e) {}
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
