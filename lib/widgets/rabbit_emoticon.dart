import 'package:flutter/material.dart';

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
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const RabbitEmoticon({
    Key? key,
    required this.emotion,
    this.size = 180,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.white,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          _assetPathForEmotion(emotion),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _assetPathForEmotion(RabbitEmotion emotion) {
    switch (emotion) {
      case RabbitEmotion.happy:
        return 'assets/emoticons/rabbit-happy.jpg';
      case RabbitEmotion.sad:
        return 'assets/emoticons/rabbit-sad.jpg';
      case RabbitEmotion.angry:
        return 'assets/emoticons/rabbit-angry.jpg';
      case RabbitEmotion.excited:
        return 'assets/emoticons/rabbit-excited.jpg';
      case RabbitEmotion.calm:
        return 'assets/emoticons/rabbit-calm.jpg';
      case RabbitEmotion.anxious:
        return 'assets/emoticons/rabbit-anxious.jpg';
      case RabbitEmotion.love:
        return 'assets/emoticons/rabbit-love.jpg';
      case RabbitEmotion.tired:
        return 'assets/emoticons/rabbit-tired.jpg';
      case RabbitEmotion.despair:
        return 'assets/emoticons/rabbit-despair.jpg';
      case RabbitEmotion.confidence:
        return 'assets/emoticons/rabbit-confidence.jpg';
    }
  }
}