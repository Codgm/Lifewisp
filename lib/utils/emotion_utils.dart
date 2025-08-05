import '../widgets/rabbit_emoticon.dart';

const Map<String, RabbitEmotion> emotionEmoji = {
  'happy': RabbitEmotion.happy,
  'sad': RabbitEmotion.sad,
  'angry': RabbitEmotion.angry,
  'anxious': RabbitEmotion.anxious,
  'tired': RabbitEmotion.tired,
  'love': RabbitEmotion.love,
  'calm': RabbitEmotion.calm,
  'excited': RabbitEmotion.excited,
  'despair': RabbitEmotion.despair,
  'confidence': RabbitEmotion.confidence,
};

// 이모지 문자열로의 매핑 (기존 코드 호환성)
const Map<String, String> emotionEmojiString = {
  'happy': '😊',
  'sad': '😢',
  'angry': '😡',
  'anxious': '😰',
  'tired': '😴',
  'love': '😍',
  'calm': '😌',
  'excited': '🤩',
  'despair': '😞',
  'confidence': '😤',
};

final Map<String, String> emotionImage = {
  'joy': 'assets/emotions/joy_bean.png',
  'sad': 'assets/emotions/sad_bean.png',
  'angry': 'assets/emotions/angry_bean.png',
  'surprise': 'assets/emotions/surprise_bean.png',
  'calm': 'assets/emotions/calm_bean.png',
  'love': 'assets/emotions/love_bean.png',
  'tired': 'assets/emotions/tired_bean.png',
}; 