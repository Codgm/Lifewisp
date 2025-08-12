class User {
  final String userId;
  final String nickname;
  final String? email;
  final String? photoUrl;
  final bool isPremium;
 
  User({
    required this.userId, 
    required this.nickname, 
    this.email, 
    this.photoUrl, 
    this.isPremium = false
  });

  User copyWith({
    String? userId,
    String? nickname,
    String? email,
    String? photoUrl,
    bool? isPremium,
  }) {
    return User(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}