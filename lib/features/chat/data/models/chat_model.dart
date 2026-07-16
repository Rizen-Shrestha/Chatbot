import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatModel extends ChatMessage {
  const ChatModel({
    required super.id,
    required super.text,
    required super.sender,
    required super.timestamp,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      text: data['text'] ?? '',
      sender: data['sender'] ?? 'user',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
