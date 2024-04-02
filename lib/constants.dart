import 'package:flutter/material.dart';

const Color kBackgroundColor = Colors.white;
const Color kTextColor = Colors.blue;
const InputDecoration kTextInputDecoration = InputDecoration(
  border: OutlineInputBorder(),
  hintText: '',
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kTextColor, width: 2.0),
  ),
);
