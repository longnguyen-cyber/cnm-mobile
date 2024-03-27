import 'package:flutter/material.dart';
import 'package:zalo_app/screens/chat/constants.dart';

class RecordFunction extends StatelessWidget {
  const RecordFunction({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
  });
  final String title;
  final IconData icon;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            // color: Colors.white,
            size: 40,
          ),
        ),
      ),
      Text(title)
    ]);
  }
}

class RecordWidgetStart extends StatelessWidget {
  const RecordWidgetStart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            const Text(
              recordMessage,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              child: Container(
                  // padding:
                  //     const EdgeInsets.all(
                  //         20),
                  // color: Colors.blue,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 50,
                    ),
                  )),
            )
          ])),
    );
  }
}
