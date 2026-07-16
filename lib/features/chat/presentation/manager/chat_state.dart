import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatHistoryLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String activeStreamingChunk;

  const ChatHistoryLoaded(this.messages, {this.activeStreamingChunk = ""});

  @override
  List<Object?> get props => [messages, activeStreamingChunk];
}

class ChatFailure extends ChatState {
  final String error;

  const ChatFailure(this.error);

  @override
  List<Object?> get props => [error];
}
