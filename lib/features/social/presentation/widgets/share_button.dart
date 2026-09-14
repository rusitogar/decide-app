import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.decisionId, required this.title});

  final String decisionId;
  final String title;

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: '$title\n\nhttps://decide.app/decision/$decisionId',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      ),
    );
    await FirebaseAnalytics.instance.logShare(
      contentType: 'decision',
      itemId: decisionId,
      method: 'share_sheet',
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      tooltip: 'Compartir',
      onPressed: () => _share(context),
    );
  }
}
