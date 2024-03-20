import 'package:audioplayers/audioplayers.dart';
import 'package:sizer/sizer.dart';
import 'package:record/record.dart';

class VoiceController {
  final AudioRecorder audioRecorder;
  final AudioPlayer audioPlayer;
  bool isRecording = false;

  VoiceController({required this.audioRecorder, required this.audioPlayer});

  Future<void> record() async {
    try {
      if (await audioRecorder.hasPermission()) {
        final stream = await audioRecorder
            .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));
      }

      final path = await audioRecorder.stop();

      // upload to s3 api
    } catch (e) {
      print(e);
    }
  }
}

class AudioDuration {
  static double calculate(Duration soundDuration) {
    if (soundDuration.inSeconds > 60) {
      return 70.w;
    } else if (soundDuration.inSeconds > 50) {
      return 65.w;
    } else if (soundDuration.inSeconds > 40) {
      return 60.w;
    } else if (soundDuration.inSeconds > 30) {
      return 55.w;
    } else if (soundDuration.inSeconds > 20) {
      return 50.w;
    } else if (soundDuration.inSeconds > 10) {
      return 45.w;
    } else {
      return 40.w;
    }
  }
}
