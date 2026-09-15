import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/image_upload_service.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/user_providers.dart';

const _avatarPalette = [0xFF6750A4, 0xFF386A20, 0xFFB3261E, 0xFF00629E, 0xFF7D5260, 0xFF9C4146];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _imageUploadService = ImageUploadService();
  int? _avatarColor;
  String? _newAvatarUrl;
  bool _initialized = false;
  bool _uploadingAvatar = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(String uid) async {
    final file = await _imageUploadService.pickImage();
    if (file == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final url = await _imageUploadService.upload(file: file, path: 'avatars/$uid/avatar.jpg');
      if (!mounted) return;
      setState(() => _newAvatarUrl = url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo subir la foto.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _submit(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    final failure = await ref.read(editProfileControllerProvider.notifier).save(
          uid: uid,
          username: _usernameController.text,
          displayName: _displayNameController.text,
          bio: _bioController.text,
          avatarColor: _avatarColor ?? _avatarPalette.first,
          avatarUrl: _newAvatarUrl,
        );

    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final profileAsync = ref.watch(userProfileProvider(uid));
    final isSaving = ref.watch(editProfileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('Perfil no encontrado.'));

          if (!_initialized) {
            _usernameController.text = profile.username;
            _displayNameController.text = profile.displayName;
            _bioController.text = profile.bio;
            _avatarColor = profile.avatarColor;
            _initialized = true;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _uploadingAvatar ? null : () => _pickAvatar(uid),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Color(_avatarColor ?? profile.avatarColor),
                                backgroundImage: _newAvatarUrl != null
                                    ? NetworkImage(_newAvatarUrl!)
                                    : (profile.avatarUrl.isNotEmpty ? NetworkImage(profile.avatarUrl) : null),
                                child: _newAvatarUrl == null && profile.avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                                    : null,
                              ),
                              if (_uploadingAvatar)
                                const CircularProgressIndicator()
                              else
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Color de avatar (se usa si no tenés foto)', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: _avatarPalette.map((color) {
                          final selected = _avatarColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _avatarColor = color),
                            child: CircleAvatar(
                              radius: selected ? 22 : 18,
                              backgroundColor: Color(color),
                              child: selected ? const Icon(Icons.check, color: Colors.white) : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Usuario', prefixText: '@'),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Ingresá un usuario';
                          if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(v)) {
                            return '3-20 caracteres: letras, números o _';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(labelText: 'Nombre visible'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'Biografía'),
                        maxLines: 3,
                        maxLength: 160,
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Tema', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final themeMode = ref.watch(themeModeProvider);
                          return SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.brightness_auto)),
                              ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode)),
                              ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.dark_mode)),
                            ],
                            selected: {themeMode},
                            onSelectionChanged: (selection) =>
                                ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: isSaving ? null : () => _submit(uid),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
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
