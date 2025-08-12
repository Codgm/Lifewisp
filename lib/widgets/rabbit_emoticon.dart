import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum RabbitEmotion {
  happy,    // 행복
  sad,      // 슬픔
  angry,    // 분노
  excited,  // 흥분
  calm,     // 평온
  anxious,  // 불안
  love,     // 사랑
  tired,    // 피곤
  despair, // 절망
  confidence,  // 자신감
}

class RabbitEmoticon extends StatelessWidget {
  final RabbitEmotion emotion;
  final double size;
  final Color? color;  // SVG 색상 오버라이드용

  const RabbitEmoticon({
    Key? key,
    required this.emotion,
    this.size = 180,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPathForEmotion(emotion),
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }

  String _assetPathForEmotion(RabbitEmotion emotion) {
    switch (emotion) {
      case RabbitEmotion.happy:
        return 'assets/emoticons/fuzz-happy.svg';
      case RabbitEmotion.sad:
        return 'assets/emoticons/fuzz-sad.svg';
      case RabbitEmotion.angry:
        return 'assets/emoticons/fuzz-angry.svg';
      case RabbitEmotion.excited:
        return 'assets/emoticons/fuzz-excited.svg';
      case RabbitEmotion.calm:
        return 'assets/emoticons/fuzz-calm.svg';
      case RabbitEmotion.anxious:
        return 'assets/emoticons/fuzz-anxious.svg';
      case RabbitEmotion.love:
        return 'assets/emoticons/fuzz-love.svg';
      case RabbitEmotion.tired:
        return 'assets/emoticons/fuzz-tired.svg';
      case RabbitEmotion.despair:
        return 'assets/emoticons/fuzz-despair.svg';
      case RabbitEmotion.confidence:
        return 'assets/emoticons/fuzz-confidence.svg';
    }
  }
}