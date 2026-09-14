import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

class OAuthButtons extends ConsumerWidget {
  const OAuthButtons({super.key, this.onSuccess});

  /// Se llama cuando el login termina bien (por ejemplo, para cerrar la
  /// pantalla de registro y volver a la anterior).
  final VoidCallback? onSuccess;

  Future<void> _signIn(BuildContext context, WidgetRef ref, OAuthProviderType provider) async {
    final result = await ref.read(authControllerProvider.notifier).signInWithOAuth(provider);
    if (!context.mounted) return;
    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.failure!.message)));
    } else if (result.signedIn) {
      onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('o')),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: isLoading ? null : () => _signIn(context, ref, OAuthProviderType.google),
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Continuar con Google'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: isLoading ? null : () => _signIn(context, ref, OAuthProviderType.microsoft),
          icon: const Icon(Icons.window_outlined, size: 20),
          label: const Text('Continuar con Microsoft'),
        ),
      ],
    );
  }
}
