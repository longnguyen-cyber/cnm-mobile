import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zalo_app/screens/chat/controllers/voice_controller.dart';

import 'record_widget_start.dart';

class OnRecordMessage extends StatelessWidget {
  const OnRecordMessage({
    super.key,
    required this.voiceController,
  });

  final VoiceController voiceController;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.4,
      width: size.width,
      // color: Colors.white,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: size.width * 0.8,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(18.0)),
              child: const Center(
                  child: Text(
                'Đang ghi âm...',
              )),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RecordFunction(
                  icon: FontAwesomeIcons.trash,
                  title: 'Huỷ',
                  onPressed: () {
                    voiceController.stop();
                  },
                ),
                RecordFunction(
                  icon: Icons.send,
                  title: 'Gửi',
                  onPressed: () {},
                ),
                RecordFunction(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  title: 'Nghe lại',
                  onPressed: () {},
                )
              ],
            )
          ]),
    );
  }
}
