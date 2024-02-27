import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FriendTabItem extends StatelessWidget {
  const FriendTabItem(
      {super.key, required this.iconUrl, required this.name, this.subtitle});
  final String iconUrl;
  final String name;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
        child: SizedBox(
            width: size.width,
            child: Row(children: [
              const Spacer(),
              Container(
                padding: EdgeInsets.all(size.width * 0.01),
                decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(10)),
                child: SvgPicture.asset(
                  iconUrl,
                  width: size.width * 0.08,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle == null
                        ? const Text('Empty Empty Empty Empty E',
                            style: TextStyle(color: Colors.white))
                        : Text(subtitle!,
                            style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Spacer(
                flex: 6,
              )
            ])),
      ),
    );
  }
}
