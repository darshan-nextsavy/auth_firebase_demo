class Post {
  final String text;
  final String uid;
  String? profileUrl;
  String? name;
  final int timestamp;
  final bool status;
  // final DateTime timestamp;

  Post(
      {required this.text,
      required this.uid,
      required this.timestamp,
      required this.status,
      this.name,
      this.profileUrl});

  factory Post.fromJson(Map<String, dynamic> data) {
    return Post(
        text: data['text'],
        uid: data['uid'],
        timestamp: data['timestamp'],
        name: data['name'],
        status: data['status'],
        profileUrl: 'profileUrl');
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'uid': uid,
        'status': status,
        'timestamp': timestamp,
        'name': name,
        'profileUrl': profileUrl
      };
}
