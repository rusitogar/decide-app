import 'package:equatable/equatable.dart';

class DecisionOption extends Equatable {
  const DecisionOption({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.link,
    required this.previewTitle,
    required this.previewImage,
    required this.previewSite,
    required this.order,
  });

  final String id;
  final String text;
  final String imageUrl;

  /// Link externo opcional a un producto/publicación (MercadoLibre, Amazon,
  /// YouTube, etc.) que ayuda a decidir entre las opciones.
  final String link;

  /// Título, imagen y sitio del link, obtenidos automáticamente al crear la
  /// decisión (igual que el preview que arma WhatsApp). Vacíos si `link`
  /// está vacío o si no se pudo obtener el preview.
  final String previewTitle;
  final String previewImage;
  final String previewSite;

  final int order;

  @override
  List<Object?> get props =>
      [id, text, imageUrl, link, previewTitle, previewImage, previewSite, order];
}
