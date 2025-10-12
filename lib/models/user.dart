class User {
  final String uid;
  final String username;
  final String email;
  final String avatar;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'avatar': avatar,
    };
  }
}