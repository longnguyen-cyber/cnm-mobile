import 'package:flutter/material.dart';

class PopoverModal extends StatefulWidget {
  const PopoverModal({super.key});

  @override
  State<PopoverModal> createState() => _PopoverModalState();
}

class _PopoverModalState extends State<PopoverModal> {
  bool _showPopover = false;

  void _togglePopover() {
    setState(() {
      _showPopover = !_showPopover;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
