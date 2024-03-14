import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zalo_app/screens/chat/components/count_down_voice_message.dart';

class VoiceMessenge extends StatefulWidget {
  const VoiceMessenge({super.key});

  @override
  State<VoiceMessenge> createState() => _VoiceMessengeState();
}

class _VoiceMessengeState extends State<VoiceMessenge> {
  final FaIcon _iconPlay =
      const FaIcon(FontAwesomeIcons.play, color: Colors.blue);
  final FaIcon _iconPause =
      const FaIcon(FontAwesomeIcons.pause, color: Colors.blue);
  bool _isPlay = false;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Row(
        children: [
          IconButton(
            icon: _isPlay ? _iconPause : _iconPlay,
            onPressed: () {
              setState(() {
                _isPlay = !_isPlay;
                _handleIsRunningChanged(_isPlay);
              });
            },
          ),
          CountDownVoiceMessage(
            isRunning: _isPlay,
            deadLine: DateTime.now()
                .add(const Duration(seconds: 10, minutes: 2, hours: 0)),
            onChanged: _handleIsRunningChanged,
          )
        ],
      ),
    );
  }

  void _handleIsRunningChanged(bool isRunning) {
    setState(() {
      print(isRunning);
      _isPlay = isRunning;
    });
  }
}
