import 'package:flutter/material.dart';

import 'index.dart';

class CustomBottomScreen extends StatelessWidget {
  const CustomBottomScreen({
    super.key,
    required this.textButton,
    required this.question,
    this.heroTag = '',
    required this.buttonPressed,
    required this.questionPressed,
  });
  final String textButton;
  final String question;
  final String heroTag;
  final Function buttonPressed;
  final Function questionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                questionPressed();
              },
              child: Text(question),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Hero(
              tag: heroTag,
              child: CustomButton(
                buttonText: textButton,
                width: 150,
                onPressed: () {
                  buttonPressed();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
