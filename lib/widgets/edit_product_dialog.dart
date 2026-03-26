import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class EditProductDialog extends StatefulWidget {
  final Product3D product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _polygonController;
  late String _selectedCategory;
  late bool _hasAnimation;
  late bool _hasRigging;
  bool _isSubmitting = false;

  final List<String> _categoryOptions = [
    'Architecture',
    'Véhicules',
    'Personnages',
    'Nature',
    'Mobilier',
    'Sci-Fi',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.name);
    _descriptionController = TextEditingController(text: p.description ?? '');
    _priceController = TextEditingController(
        text: p.price != null && p.price! > 0 ? p.price!.toStringAsFixed(2) : '');
    _imageUrlController = TextEditingController(text: p.imageUrl ?? '');
    _polygonController = TextEditingController(
        text: p.nbPolygone > 0 ? p.nbPolygone.toString() : '');
    _selectedCategory = _categoryOptions.contains(p.categorie)
        ? p.categorie
        : 'Autre';
    _hasAnimation = p.animation;
    _hasRigging = p.ringing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _polygonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Titre ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Modifier le modèle',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Nom ──
                  _buildLabel('Nom du modèle *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(hintText: 'Nom'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 18),

                  // ── Description ──
                  _buildLabel('Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Description...'),
                  ),
                  const SizedBox(height: 18),

                  // ── Prix ──
                  _buildLabel('Prix (€)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '0.00'),
                  ),
                  const SizedBox(height: 18),

                  // ── URL Image ──
                  _buildLabel('URL de l\'image'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _imageUrlController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'https://exemple.com/image.png'),
                  ),
                  const SizedBox(height: 18),

                  // ── Catégorie + Polygones ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Catégorie'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              dropdownColor: AppTheme.cardDark,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary),
                              decoration: const InputDecoration(),
                              items: _categoryOptions
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Nb Polygones'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _polygonController,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary),
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(hintText: '10000'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Checkboxes ──
                  Row(
                    children: [
                      _buildCheckbox('Animation', _hasAnimation,
                          (v) => setState(() => _hasAnimation = v!)),
                      const SizedBox(width: 24),
                      _buildCheckbox('Rigging', _hasRigging,
                          (v) => setState(() => _hasRigging = v!)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Boutons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _isSubmitting ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: AppTheme.buttonRadius,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryPurple,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ApiService.updateModele(
      id: widget.product.id,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      prix: double.tryParse(_priceController.text),
      url: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      categorie: _selectedCategory,
      nbPolygone: int.tryParse(_polygonController.text),
      animation: _hasAnimation,
      ringing: _hasRigging,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modèle modifié avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la modification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
