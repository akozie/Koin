import 'package:equatable/equatable.dart';

/// A motivational quote fetched from the DummyJSON public API.
class Quote extends Equatable {
  const Quote({required this.id, required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) =>
      Quote(id: json['id'] as int, text: json['quote'] as String, author: json['author'] as String);

  final int id;
  final String text;
  final String author;

  /// Same shape as the API so cached and fresh data share [Quote.fromJson].
  Map<String, dynamic> toJson() => {'id': id, 'quote': text, 'author': author};

  @override
  List<Object?> get props => [id, text, author];
}
