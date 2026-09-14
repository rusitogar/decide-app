import 'package:equatable/equatable.dart';

class DecisionOption extends Equatable {
  const DecisionOption({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.link,
    required this.order,
  });

  final String id;
  final String text;
  final String imageUrl;

  /// Link externo opcional a un producto/publicación (MercadoLibre, Amazon,
  /// YouTube, etc.) que ayuda a decidir entre las opciones.
  final String link;

  final int order;

  @override
  List<Object?> get props => [id, text, imageUrl, link, order];
}
