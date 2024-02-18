import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.textField});
  final TextFormField textField;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(20),
      //   border: Border.all(
      //     width: 2.5,
      //     color: kTextColor,
      //   ),
      // ),
      child: textField,
    );
  }
}
