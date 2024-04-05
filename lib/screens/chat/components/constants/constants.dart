import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

var smileEmoji = SvgPicture.asset(
  'assets/icons/laughing-emoji.svg',
  width: 32,
  height: 32,
);

const sadEmoji = Image(
  image: AssetImage('assets/icons/sad.png'),
  width: 24,
  height: 24,
);

var angryEmoji = const Image(
  image: AssetImage('assets/icons/angry-32.png'),
  width: 28,
  height: 28,
);

var likeEmoji = const Image(
  image: AssetImage('assets/icons/like.png'),
  width: 32,
  height: 32,
);

var laughingEmoji = const Image(
  image: AssetImage('assets/icons/laughing.png'),
  width: 32,
  height: 32,
);

var loveEmoji = const Image(
  image: AssetImage('assets/icons/thumbs-up-32.png'),
  width: 32,
  height: 32,
);
