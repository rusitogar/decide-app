import 'package:equatable/equatable.dart';

class DecisionOption extends Equatable {
  const DecisionOption({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.order,
  });

  final String id;
  final String text;
  final String imageUrl;
  final int order;

  @override
  List<Object?> get props => [id, text, imageUrl, order];
}
