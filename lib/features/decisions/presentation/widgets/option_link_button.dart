import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OptionLinkButton extends StatelessWidget {
  const OptionLinkButton({super.key, required this.link});

  final String link;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(link);
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
    return IconButton(
      icon: const Icon(Icons.open_in_new, size: 18),
      tooltip: 'Ver producto',
      onPressed: () => _open(context),
    );
  }
}
