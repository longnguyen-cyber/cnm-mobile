import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.url});
  final Uri url;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late CustomVideoPlayerController _customVideoPlayerController;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !isPlaying
            ? Container()
            : CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController,
              ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  void initializePlayer() {
    VideoPlayerController videoPlayerController;

    videoPlayerController = VideoPlayerController.networkUrl(widget.url)
      ..initialize().then((value) {
        setState(() {
          isPlaying = true;
        });
      });

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
  }
}
