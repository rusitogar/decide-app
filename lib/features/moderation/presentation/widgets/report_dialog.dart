import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/moderation_repository.dart';
import '../providers/moderation_providers.dart';

Future<void> showReportDialog(
  BuildContext context,
  WidgetRef ref, {
  required String reporterId,
  required ReportTargetType targetType,
  required String targetId,
}) async {
  final controller = TextEditingController();

  final reason = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reportar'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Contanos brevemente el motivo...'),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Enviar'),
        ),
      ],
    ),
  );

  if (reason == null || !context.mounted) return;

  final failure = await ref
      .read(reportControllerProvider.notifier)
      .submit(reporterId: reporterId, targetType: targetType, targetId: targetId, reason: reason);

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(failure?.message ?? 'Gracias, lo vamos a revisar.')),
  );
}
