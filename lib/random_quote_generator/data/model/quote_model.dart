class QuoteModel {
  String? author;
  String? content;

  QuoteModel({required this.author, required this.content});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      author: json['author'],
      content: json['content'],
    );
  }
}
