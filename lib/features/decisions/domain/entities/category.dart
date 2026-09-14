import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name, required this.order});

  final String id;
  final String name;
  final int order;

  @override
  List<Object?> get props => [id, name, order];
}
