import 'package:chat_app/widgets/message_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final autheticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatsnapshots) {
          if (chatsnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatsnapshots.hasData || chatsnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found.'),
            );
          }
          if (chatsnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong.'),
            );
          }
          final loadMessage = chatsnapshots.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadMessage.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadMessage[index].data();
                final nextCHatMessage = index + 1 < loadMessage.length
                    ? loadMessage[index].data()
                    : null;
                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextCHatMessage != null ? nextCHatMessage['userId'] : null;

                final nextUserIsSame =
                    currentMessageUserId == nextMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: autheticatedUser.uid == currentMessageUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: autheticatedUser.uid == currentMessageUserId,
                  );
                }
              });
        });
  }
}
