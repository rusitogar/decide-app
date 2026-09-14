import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../social/presentation/widgets/follow_button.dart';
import '../providers/user_providers.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(uid));
    final countsAsync = ref.watch(profileCountsProvider(uid));
    final currentUid = ref.watch(authRepositoryProvider).currentUser?.uid;
    final isOwnProfile = currentUid == uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
              onPressed: () => context.push('/profile/edit'),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Este perfil no existe.'));
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  UserAvatar(profile: profile, radius: 44),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName.isNotEmpty ? profile.displayName : '@${profile.username}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('@${profile.username}', style: Theme.of(context).textTheme.bodyMedium),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(profile.bio, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 20),
                  countsAsync.when(
                    data: (counts) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => context.push('/profile/$uid/decisions'),
                          child: _CountItem(label: 'Decisiones', value: counts.decisions),
                        ),
                        const SizedBox(width: 24),
                        _CountItem(label: 'Seguidores', value: counts.followers),
                        const SizedBox(width: 24),
                        _CountItem(label: 'Siguiendo', value: counts.following),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  if (!isOwnProfile && currentUid != null) ...[
                    const SizedBox(height: 20),
                    FollowButton(currentUid: currentUid, targetUid: uid),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _CountItem extends StatelessWidget {
  const _CountItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
