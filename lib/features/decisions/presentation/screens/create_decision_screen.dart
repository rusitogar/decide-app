import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/decision_providers.dart';

class CreateDecisionScreen extends ConsumerStatefulWidget {
  const CreateDecisionScreen({super.key});

  @override
  ConsumerState<CreateDecisionScreen> createState() => _CreateDecisionScreenState();
}

class _CreateDecisionScreenState extends ConsumerState<CreateDecisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _linkControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String? _category;
  DateTime? _closesAt;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    for (final c in _linkControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length >= 5) return;
    setState(() {
      _optionControllers.add(TextEditingController());
      _linkControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers.removeAt(index).dispose();
      _linkControllers.removeAt(index).dispose();
    });
  }

  Future<void> _pickClosesAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _closesAt = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí una categoría.')),
      );
      return;
    }

    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) return;

    final options = [
      for (var i = 0; i < _optionControllers.length; i++)
        (text: _optionControllers[i].text, link: _linkControllers[i].text),
    ];

    final result = await ref.read(createDecisionControllerProvider.notifier).create(
          authorId: uid,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category!,
          options: options,
          closesAt: _closesAt,
        );

    if (!mounted) return;
    if (result.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.failure!.message)));
    } else if (result.id != null) {
      context.pushReplacement('/decision/${result.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isSaving = ref.watch(createDecisionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva decisión')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: '¿Qué querés que decidan?'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => const Text('No se pudieron cargar las categorías.'),
                    ),
                    const SizedBox(height: 24),
                    Text('Opciones (2 a 5)', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Podés sumar un link de referencia por opción (MercadoLibre, Amazon, '
                      'YouTube, etc.) para que sea más fácil decidir.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < _optionControllers.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _optionControllers[i],
                                    decoration: InputDecoration(labelText: 'Opción ${i + 1}'),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty) ? 'Completá esta opción' : null,
                                  ),
                                ),
                                if (_optionControllers.length > 2)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeOption(i),
                                  ),
                              ],
                            ),
                            TextFormField(
                              controller: _linkControllers[i],
                              decoration: const InputDecoration(
                                labelText: 'Link (opcional)',
                                prefixIcon: Icon(Icons.link, size: 18),
                              ),
                              keyboardType: TextInputType.url,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final uri = Uri.tryParse(v.trim());
                                if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
                                  return 'Tiene que empezar con http:// o https://';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    if (_optionControllers.length < 5)
                      OutlinedButton.icon(
                        onPressed: _addOption,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar opción'),
                      ),
                    const SizedBox(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_closesAt == null
                          ? 'Sin fecha de cierre'
                          : 'Cierra el ${_closesAt!.day}/${_closesAt!.month}/${_closesAt!.year}'),
                      trailing: TextButton(
                        onPressed: _pickClosesAt,
                        child: Text(_closesAt == null ? 'Elegir fecha' : 'Cambiar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: isSaving ? null : _submit,
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Publicar decisión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
