// lib/widgets/favorite_button.dart
import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class FavoriteButton extends StatefulWidget {
  final int book;
  final int chapter;
  final int verse;
  final String text;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    Key? key,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() async {
    // Animação
    await _animationController.forward();
    await _animationController.reverse();
    
    // Toggle favorito
    await _favoritesService.toggleFavorite(
      widget.book, 
      widget.chapter, 
      widget.verse, 
      widget.text
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _favoritesService,
      builder: (context, child) {
        final isFavorite = _favoritesService.isFavorite(
          widget.book, 
          widget.chapter, 
          widget.verse
        );
        
        return ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            onPressed: _onTap,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: widget.size,
              color: isFavorite 
                ? (widget.activeColor ?? Colors.red) 
                : (widget.inactiveColor ?? Colors.grey),
            ),
          ),
        );
      },
    );
  }
}