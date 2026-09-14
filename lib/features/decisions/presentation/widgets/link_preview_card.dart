import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/decision_option.dart';

/// Tarjeta de preview de un link, similar a la que muestra WhatsApp: imagen,
/// título y sitio de origen, sin necesidad de entrar al link.
class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({super.key, required this.option});

  final DecisionOption option;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(option.link);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPreview = option.previewTitle.isNotEmpty;
    final site = option.previewSite.isNotEmpty ? option.previewSite : (Uri.tryParse(option.link)?.host ?? '');

    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: option.previewImage.isNotEmpty
                  ? Image.network(
                      option.previewImage,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _LinkIconBox(),
                    )
                  : const _LinkIconBox(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasPreview ? option.previewTitle : 'Ver producto',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (site.isNotEmpty)
                    Text(
                      site,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                    ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 16),
          ],
        ),
      ),
    );
  }
}

class _LinkIconBox extends StatelessWidget {
  const _LinkIconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.link, size: 24),
    );
  }
}
