import 'dart:async';
import 'package:flutter/material.dart';

class CountDownVoiceMessage extends StatefulWidget {
  const CountDownVoiceMessage(
      {super.key,
      required this.deadLine,
      this.textStyle,
      required this.isRunning,
      required this.onChanged});
  final DateTime deadLine;
  final TextStyle? textStyle;
  final bool isRunning;
  final Function(bool) onChanged;

  @override
  State<CountDownVoiceMessage> createState() => _CountDownVoiceMessageState();
}

class _CountDownVoiceMessageState extends State<CountDownVoiceMessage> {
  late Timer timer;
  Duration duration = const Duration();
  @override
  void initState() {
    super.initState();
    calculateTimeLeft(widget.deadLine);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      calculateTimeLeft(widget.deadLine);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.textStyle ?? const TextStyle(color: Colors.black);
    // final labelStyle = widget.labelStyle ?? const TextStyle();
    final hours = DefaultTextStyle(
        style: textStyle,
        child: Text(duration.inHours.toString().padLeft(2, '0')));
    final minutes = DefaultTextStyle(
        style: textStyle,
        child:
            Text(duration.inMinutes.remainder(60).toString().padLeft(2, '0')));
    final seconds = DefaultTextStyle(
        style: textStyle,
        child: Text(
          duration.inSeconds.remainder(60).toString().padLeft(2, '0'),
        ));

    return Container(
        child: widget.isRunning
            ? Row(children: [
                hours,
                const Text(' : '),
                minutes,
                const Text(' : '),
                seconds
              ])
            : Text(printDuration(duration)));
  }

  void calculateTimeLeft(DateTime deadLine) {
    final senconds = deadLine.difference(DateTime.now()).inSeconds;
    // if (isRunning) {
    setState(() {
      duration = Duration(seconds: senconds);
      if (duration <= Duration.zero) {
        duration = const Duration();
        widget.onChanged(false);
      }
    });
    // }
  }

  String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    twoDigits(duration.inMinutes.remainder(60).abs()).toString();
    twoDigits(duration.inSeconds.remainder(60).abs()).toString();
    return "00 : 02 : 09";
  }
}
