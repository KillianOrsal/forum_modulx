import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../screens/auth_screen.dart';
import '../widgets/gradient_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product3D product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product3D _product;
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoadingDetail = true);
    final detail = await ApiService.fetchModeleDetail(_product.id);
    if (detail != null && mounted) {
      setState(() {
        _product = detail;
        _isLoadingDetail = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingDetail = false);
    }
  }

  Future<void> _submitComment() async {
    final auth = AuthService();

    // Si pas connecté → ouvrir l'écran de connexion
    if (!auth.isLoggedIn) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (result != true || !mounted) return;
      setState(() {}); // Rafraîchir pour montrer le champ avec le nom
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);

    final success = await ApiService.addComment(
      _product.id,
      text,
      auth.currentUser!.idUser,
    );

    if (!mounted) return;
    setState(() => _isSubmittingComment = false);

    if (success) {
      _commentController.clear();
      await _loadDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ajout du commentaire'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            _buildTopBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 20 : 80,
                  vertical: 40,
                ),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(),
                          const SizedBox(height: 30),
                          _buildInfoSection(context),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildImageSection()),
                          const SizedBox(width: 50),
                          Expanded(flex: 4, child: _buildInfoSection(context)),
                        ],
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 20 : 80,
                ),
                child: _buildTechnicalSection(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 20 : 80,
                  vertical: 40,
                ),
                child: _buildCommentsSection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withValues(alpha: 0.9),
          border: const Border(
            bottom: BorderSide(color: AppTheme.borderColor),
          ),
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppTheme.textPrimary, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.view_in_ar,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ModulX',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: AppTheme.cardRadius,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: _product.imageUrl != null && _product.imageUrl!.isNotEmpty
            ? Image.network(
                _product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.placeholderGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar,
                size: 64,
                color: AppTheme.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'Aperçu non disponible',
              style: TextStyle(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_product.categorie.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _product.categorie,
              style: const TextStyle(
                color: AppTheme.primaryPurpleLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          _product.name,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                _product.authorFirstName.isNotEmpty
                    ? _product.authorFirstName[0].toUpperCase()
                    : 'A',
                style: TextStyle(
                  color: AppTheme.primaryPurpleLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _product.authorName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: AppTheme.cardRadius,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Text(
                _product.priceFormatted,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.comment_outlined,
                      size: 16, color: AppTheme.accentBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${_product.comments.length} commentaire${_product.comments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_product.description != null &&
            _product.description!.isNotEmpty) ...[
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: AppTheme.cardRadius,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              _product.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTechnicalSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spécifications techniques',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _techBadge(
                  Icons.category, 'Polygones', _product.polygoneFormatted),
              _techBadge(Icons.animation, 'Animation',
                  _product.animation ? 'Oui' : 'Non'),
              _techBadge(Icons.accessibility_new, 'Rigging',
                  _product.ringing ? 'Oui' : 'Non'),
              if (_product.categorie.isNotEmpty)
                _techBadge(Icons.folder_open, 'Catégorie', _product.categorie),
            ],
          ),
        ],
      ),
    );
  }

  Widget _techBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryPurpleLight),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    final auth = AuthService();
    final isLoggedIn = auth.isLoggedIn;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Commentaires',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_product.comments.length}',
                  style: const TextStyle(
                    color: AppTheme.primaryPurpleLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Zone de saisie ou message de connexion
          if (isLoggedIn) ...[
            // Connecté → afficher le champ de commentaire
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primaryPurple.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          auth.currentUser!.firstName.isNotEmpty
                              ? auth.currentUser!.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppTheme.primaryPurpleLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Commenter en tant que ${auth.currentUser!.fullName}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Partagez votre avis sur ce modèle...',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _isSubmittingComment
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : GradientButton(
                            text: 'Publier',
                            icon: Icons.send,
                            onPressed: _submitComment,
                          ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Non connecté → message + bouton connexion
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      color: AppTheme.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Connectez-vous pour laisser un commentaire',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    text: 'Se connecter',
                    icon: Icons.login,
                    onPressed: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                            builder: (_) => const AuthScreen()),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Liste des commentaires
          if (_isLoadingDetail)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: AppTheme.primaryPurple),
              ),
            )
          else if (_product.comments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 36,
                      color: AppTheme.textMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun commentaire pour le moment',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  Text(
                    'Soyez le premier à donner votre avis !',
                    style:
                        TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_product.comments.length, (index) {
              final comment = _product.comments[index];
              return Container(
                margin: EdgeInsets.only(
                    bottom: index < _product.comments.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.primaryPurple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        comment.firstName.isNotEmpty
                            ? comment.firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppTheme.primaryPurpleLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.description,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
