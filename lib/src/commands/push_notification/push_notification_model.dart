class Payload {
  Payload({
    required this.title,
    required this.body,
    required this.badge,
  });
  final String title;
  final String body;
  final String badge;

  Map<String, dynamic> toJson() {
    return {
      'aps': {
        'alert': {
          'title': title,
          'body': body,
        },
        'badge': badge,
      },
    };
  }
}
