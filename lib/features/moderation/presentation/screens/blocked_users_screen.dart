import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../users/presentation/providers/user_providers.dart';
import '../../../users/presentation/widgets/user_avatar.dart';
import '../providers/moderation_providers.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsAsync = ref.watch(blockedUserIdsProvider(ownerUid));

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios bloqueados')),
      body: idsAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(child: Text('No bloqueaste a nadie.'));
          }
          return ListView.builder(
            itemCount: ids.length,
            itemBuilder: (context, index) {
              final blockedUid = ids[index];
              final profileAsync = ref.watch(userProfileProvider(blockedUid));
              return profileAsync.when(
                data: (profile) => profile == null
                    ? const SizedBox.shrink()
                    : ListTile(
                        leading: UserAvatar(profile: profile, radius: 18),
                        title: Text(profile.displayName.isNotEmpty ? profile.displayName : '@${profile.username}'),
                        trailing: TextButton(
                          onPressed: () => ref.read(blockControllerProvider.notifier).toggle(
                                ownerUid: ownerUid,
                                blockedUid: blockedUid,
                                currentlyBlocked: true,
                              ),
                          child: const Text('Desbloquear'),
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
