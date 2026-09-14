import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/decision_providers.dart';

class EditDecisionScreen extends ConsumerStatefulWidget {
  const EditDecisionScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditDecisionScreen> createState() => _EditDecisionScreenState();
}

class _EditDecisionScreenState extends ConsumerState<EditDecisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  DateTime? _closesAt;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickClosesAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _closesAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _closesAt = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final failure = await ref.read(editDecisionControllerProvider.notifier).save(
          id: widget.id,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category ?? '',
          closesAt: _closesAt,
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
    final decisionAsync = ref.watch(decisionProvider(widget.id));
    final categoriesAsync = ref.watch(categoriesProvider);
    final isSaving = ref.watch(editDecisionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar decisión')),
      body: decisionAsync.when(
        data: (decision) {
          if (decision == null) return const Center(child: Text('Esta decisión no existe.'));

          if (!_initialized) {
            _titleController.text = decision.title;
            _descriptionController.text = decision.description;
            _category = decision.category;
            _closesAt = decision.closesAt;
            _initialized = true;
          }

          return SafeArea(
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
                          decoration: const InputDecoration(labelText: 'Título'),
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
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_closesAt == null
                              ? 'Sin fecha de cierre'
                              : 'Cierra el ${_closesAt!.day}/${_closesAt!.month}/${_closesAt!.year}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_closesAt != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() => _closesAt = null),
                                ),
                              TextButton(
                                onPressed: _pickClosesAt,
                                child: Text(_closesAt == null ? 'Elegir fecha' : 'Cambiar'),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Las opciones no se pueden editar una vez creada la decisión.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        FilledButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Guardar cambios'),
                        ),
                      ],
                    ),
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
