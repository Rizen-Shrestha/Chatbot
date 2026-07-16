import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart'; // 1. Added GoRouter import
import '../../../../core/di/injection_container.dart';
import '../manager/chat_cubit.dart';
import '../manager/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final String uid = sl<FirebaseAuth>().currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Companion Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            // 2. Changed from Navigator.pushNamed to context.push for GoRouter
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => sl<ChatCubit>()..listenToMessages(uid),
        // 3. Renamed outer builder context parameter to 'blocContext'
        // to prevent scope shadowing issues with the root Scaffold build context.
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (blocContext, state) {
            if (state is ChatInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatFailure) {
              return Center(child: Text("Error: ${state.error}"));
            }

            final chatState = state as ChatHistoryLoaded;
            final messages = chatState.messages;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                    messages.length +
                        (chatState.activeStreamingChunk.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatState.activeStreamingChunk.isNotEmpty &&
                          index == 0) {
                        return _buildMessageBubble(
                          chatState.activeStreamingChunk,
                          false,
                        );
                      }

                      final actualIndex =
                      chatState.activeStreamingChunk.isNotEmpty
                          ? index - 1
                          : index;
                      final msg = messages[actualIndex];
                      return _buildMessageBubble(
                        msg.text,
                        msg.sender == 'user',
                      );
                    },
                  ),
                ),
                // 4. Passed 'blocContext' so the composer can access ChatCubit safely
                _buildMessageComposer(blocContext),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurpleAccent : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.black26,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                hintText: "Ask anything...",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
            onPressed: () {
              final text = _controller.text;
              // 5. This context now correctly has the ChatCubit provider in its ancestral tree!
              context.read<ChatCubit>().sendChatMessage(uid, text);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}