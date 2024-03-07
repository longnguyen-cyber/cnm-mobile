import 'package:flutter/material.dart';

class ReactionChat extends StatefulWidget {
  const ReactionChat({super.key});

  @override
  State<ReactionChat> createState() => _ReactionChatState();
}

class _ReactionChatState extends State<ReactionChat> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
    );
  }
}
