import 'package:equatable/equatable.dart';

class Decision extends Equatable {
  const Decision({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.closesAt,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final DateTime? closesAt;
  final DateTime? createdAt;

  bool get isClosed => closesAt != null && closesAt!.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, authorId, title, description, category, imageUrl, closesAt, createdAt];
}
