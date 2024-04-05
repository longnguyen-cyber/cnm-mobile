import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:zalo_app/services/api_service.dart';
import 'record_widget_start.dart';
import 'package:uuid/uuid.dart';

class OnRecordMessage extends StatefulWidget {
  const OnRecordMessage({
    super.key,
    required this.audioRecord,
    required this.path,
  });
  final AudioRecorder audioRecord;
  final String path;

  @override
  State<OnRecordMessage> createState() => _OnRecordMessageState();
}

class _OnRecordMessageState extends State<OnRecordMessage> {
  final api = API();

  Future<void> _stopRecord() async {
    var path = await widget.audioRecord.stop();
    var uuid = Uuid();
    String randomFileName = uuid.v4();
    print("Stop recording: $path");

    // Create an instance of FlutterSoundHelper
    final FlutterSoundHelper audioHelper = FlutterSoundHelper();

    // Convert the audio file to mp3
    final String mp3Path = path!.replaceFirst('.wav', '.mp3');
    await audioHelper.convertFile(path, Codec.pcm16WAV, mp3Path, Codec.mp3);
    // Now you have an mp3 file at the path mp3Path
    path = mp3Path;
    print("Converted to mp3: $path");
    // Read the mp3 file as bytes
    final mp3File = File(mp3Path);
    final bytes = await mp3File.readAsBytes();

    // Get the file extension and size
    final extension = mp3Path.split(".").last;
    final size = bytes.length;

    // Create the data object
    var data = {
      "filename": randomFileName + p.basename(mp3File.path),
      "extension": extension,
      "size": size,
      "bytes": bytes,
    };

    final response = await api.uploadFile(data);
    print(response);
  }

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
                  onPressed: _stopRecord,
                ),
                RecordFunction(
                  icon: Icons.send,
                  title: 'Gửi',
                  onPressed: () {},
                ),
              ],
            )
          ]),
    );
  }
}
