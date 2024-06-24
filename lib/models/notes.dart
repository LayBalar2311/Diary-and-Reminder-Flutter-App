class Notes {
  int? id;
  String title, description;
  DateTime createdAt;

  Notes(
      {this.id,
      required this.title,
      required this.description,
      required this.createdAt});

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toString()
    };
  }
}
