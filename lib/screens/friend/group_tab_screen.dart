import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupTabScreen extends StatelessWidget {
  const GroupTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var topGroupItem = Row(children: <Widget>[
      Flexible(
        flex: 2,
        child: Container(
          padding: EdgeInsets.all(size.width * 0.01),
          decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(20)),
          child: SvgPicture.asset(
            'assets/icons/group-106.svg',
            width: size.width * 0.1,
            color: Colors.white,
          ),
        ),
      ),
      Spacer(),
      Expanded(
        flex: 8,
        child: Container(
            padding: EdgeInsets.all(size.width * 0.01),
            child: const Text('Tạo nhóm mới',
                style: TextStyle(fontSize: 16, color: Colors.blue))),
      ),
    ]);
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(size.width * 0.02),
      width: size.width,
      child: Column(children: [
        topGroupItem,
        SizedBox(
          height: size.height * 0.01,
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade300,
              ),
              height: size.height * 0.01,
              width: size.width,
              // color: Colors.grey,
            )),
          ],
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        const Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Text('Danh sách nhóm', style: TextStyle(fontSize: 16)),
            Spacer(),
            Text('Xem tất cả',
                style: TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        )
      ]),
    ));
  }
}
