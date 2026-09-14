import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/logging/app_logger.dart';

class LinkPreviewResult {
  const LinkPreviewResult({required this.title, required this.image, required this.site});

  final String title;
  final String image;
  final String site;

  static const empty = LinkPreviewResult(title: '', image: '', site: '');
}

/// Sitios que bloquean a los robots de preview y devuelven una página
/// genérica (ej. un cartel de cookies) en vez de los datos del producto.
/// Para estos, mejor no mostrar nada automático en vez de mostrar algo
/// incorrecto (como el logo del sitio en lugar de la foto real).
const _blockedPreviewHosts = ['mercadolibre.com', 'mercadolivre.com'];

/// Usa el servicio gratuito microlink.io para obtener título, imagen y sitio
/// de un link externo (Amazon, YouTube, etc.), igual que hace WhatsApp al
/// mostrar el preview de un link. Si falla, tarda de más o el sitio bloquea
/// el preview, devuelve vacío para no bloquear la creación de la decisión
/// ni mostrar datos incorrectos.
Future<LinkPreviewResult> fetchLinkPreview(String url) async {
  final host = Uri.tryParse(url)?.host ?? '';
  if (_blockedPreviewHosts.any(host.contains)) return LinkPreviewResult.empty;

  try {
    final uri = Uri.https('api.microlink.io', '/', {'url': url});
    final response = await http.get(uri).timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return LinkPreviewResult.empty;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'success') return LinkPreviewResult.empty;

    final data = body['data'] as Map<String, dynamic>? ?? {};
    final image = (data['image'] as Map<String, dynamic>?)?['url'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final site = data['publisher'] as String? ?? (Uri.tryParse(url)?.host ?? '');

    return LinkPreviewResult(title: title, image: image, site: site);
  } catch (e, st) {
    appLogger.w('fetchLinkPreview failed', error: e, stackTrace: st);
    return LinkPreviewResult.empty;
  }
}
