import 'package:flutter/material.dart';
import 'package:widget_zoom/widget_zoom.dart';

class FullScreenImage extends StatefulWidget {
  final String image;
  const FullScreenImage({
    super.key,
    required this.image,
  });

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            //!pop screen will scroll to end screen before this screen
            //! expect: hold position before view image
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                //config download image
              },
              icon: const Icon(Icons.download, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: WidgetZoom(
          heroAnimationTag: "image",
          zoomWidget: Image.network(widget.image),
        ),
      ),
    );
  }
}
