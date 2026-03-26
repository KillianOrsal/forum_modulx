import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppTheme.primaryGradient : null,
            color: widget.isSelected
                ? null
                : _isHovered
                    ? AppTheme.cardHover
                    : AppTheme.cardDark,
            borderRadius: AppTheme.chipRadius,
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : _isHovered
                      ? AppTheme.primaryPurple.withValues(alpha: 0.5)
                      : AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected
                  ? Colors.white
                  : _isHovered
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight:
                  widget.isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
