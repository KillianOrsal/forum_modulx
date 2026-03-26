import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _polygonController = TextEditingController();
  String _selectedCategory = 'Architecture';
  bool _hasAnimation = false;
  bool _hasRigging = false;
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
                        child: const Icon(Icons.add_box_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Ajouter un modèle',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ce modèle sera ajouté directement en base de données.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),

                  // ── Nom ──
                  _buildLabel('Nom du modèle *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Ex: Spaceship Alpha',
                    ),
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
                    decoration: const InputDecoration(
                      hintText: 'Décrivez votre modèle 3D...',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Prix ──
                  _buildLabel('Prix (€)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── URL Image ──
                  _buildLabel('URL de l\'image'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _imageUrlController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'https://exemple.com/image.png',
                    ),
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
                              decoration: const InputDecoration(
                                hintText: '10000',
                              ),
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
                        onPressed:
                            _isSubmitting ? null : () => Navigator.of(context).pop(false),
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
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: AppTheme.buttonRadius,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Ajouter',
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
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = AuthService();
    final success = await ApiService.addModele(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      prix: double.tryParse(_priceController.text),
      auteur: auth.currentUser?.idUser,
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
          content: Text('Modèle ajouté avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // true = ajouté avec succès
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ajout du modèle'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
