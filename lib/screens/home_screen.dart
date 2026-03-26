import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme/app_theme.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/gradient_button.dart';
import '../widgets/add_product_dialog.dart';
import 'product_detail_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product3D> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await ApiService.fetchModeles();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            'Impossible de charger les modèles. Vérifiez que le serveur est démarré.';
        _isLoading = false;
      });
    }
  }

  List<Product3D> get _filteredProducts {
    var products = _products;

    // Filtre par catégorie
    if (_selectedCategory != 'Tous') {
      products = products
          .where((p) =>
              p.categorie.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false) ||
              p.categorie.toLowerCase().contains(query))
          .toList();
    }

    return products;
  }

  List<String> get _categoryNames {
    final cats = <String>{'Tous'};
    for (final p in _products) {
      if (p.categorie.isNotEmpty) {
        cats.add(p.categorie);
      }
    }
    return cats.toList();
  }

  void _addProduct() async {
    // Vérifier que l'utilisateur est connecté
    if (!AuthService().isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() {});
    }

    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddProductDialog(),
    );
    if (result == true) {
      await _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            _buildNavBar(screenWidth),
            _buildHeroSection(screenWidth),
            _buildSearchAndFilters(screenWidth),
            _buildProductGrid(screenWidth),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(double screenWidth) {
    final isNarrow = screenWidth < 768;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 20 : 60,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withValues(alpha: 0.9),
          border: const Border(
            bottom: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.view_in_ar,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ModulX',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Forum',
                  style: TextStyle(
                    color: AppTheme.primaryPurpleLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (!isNarrow) ...[
              _navLink('Accueil', true),
              const SizedBox(width: 20),
            ],
            GradientButton(
              text: isNarrow ? '+' : 'Ajouter un modèle',
              icon: isNarrow ? null : Icons.add,
              onPressed: _addProduct,
            ),
            const SizedBox(width: 12),
            _buildAuthButton(isNarrow),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton(bool isNarrow) {
    final auth = AuthService();
    if (auth.isLoggedIn) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isNarrow) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  if (mounted) setState(() {});
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.2),
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
                      auth.currentUser!.fullName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                auth.logout();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Icon(Icons.logout,
                    color: AppTheme.textSecondary, size: 18),
              ),
            ),
          ),
        ],
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
            if (result == true && mounted) {
              setState(() {});
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login,
                    color: AppTheme.textSecondary, size: 16),
                if (!isNarrow) ...[
                  const SizedBox(width: 6),
                  const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _navLink(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(double screenWidth) {
    final isNarrow = screenWidth < 768;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 20 : 60,
          vertical: isNarrow ? 40 : 70,
        ),
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 14, color: AppTheme.primaryPurpleLight),
                  const SizedBox(width: 6),
                  Text(
                    'Forum communautaire',
                    style: TextStyle(
                      color: AppTheme.primaryPurpleLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Explorez notre collection\nde modèles 3D',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: isNarrow ? 32 : 48,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Découvrez, partagez et discutez des derniers modèles 3D ajoutés à la boutique ModulX.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isNarrow ? 14 : 16,
                  ),
            ),
            const SizedBox(height: 30),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statItem('${_products.length}', 'Modèles'),
                Container(
                  width: 1,
                  height: 30,
                  color: AppTheme.borderColor,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                ),
                _statItem('${_categoryNames.length - 1}', 'Catégories'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(double screenWidth) {
    final isNarrow = screenWidth < 768;
    final padding = isNarrow ? 20.0 : 60.0;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 40, padding, 10),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un modèle 3D...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppTheme.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            // Chips catégories
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categoryNames[i];
                  return CategoryChip(
                    label: cat,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(double screenWidth) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryPurple),
              const SizedBox(height: 16),
              Text(
                'Chargement des modèles...',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.primaryPurpleLight, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Réessayer',
                icon: Icons.refresh,
                onPressed: _loadData,
              ),
            ],
          ),
        ),
      );
    }

    final products = _filteredProducts;
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off,
                  color: AppTheme.textMuted.withValues(alpha: 0.5), size: 48),
              const SizedBox(height: 16),
              Text(
                'Aucun modèle trouvé',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez d\'autres mots-clés ou ajoutez un modèle.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final isNarrow = screenWidth < 768;
    final padding = isNarrow ? 20.0 : 60.0;
    int crossAxisCount;
    if (screenWidth >= 1400) {
      crossAxisCount = 4;
    } else if (screenWidth >= 1024) {
      crossAxisCount = 3;
    } else if (screenWidth >= 768) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return SliverPadding(
      padding: EdgeInsets.all(padding),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${products.length} modèle${products.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AlignedGridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => _openProductDetail(product),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openProductDetail(Product3D product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: const Border(
            top: BorderSide(color: AppTheme.borderColor),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  'ModulX Forum',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 ModulX - Tous droits réservés',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
