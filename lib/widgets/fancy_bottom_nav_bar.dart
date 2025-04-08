import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/design_system.dart';

class FancyBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FancyBottomNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double iconSize;
  final double activeIconSize;
  final double fontSize;
  final double activeFontSize;

  const FancyBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height = 70.0,
    this.iconSize = 22.0,
    this.activeIconSize = 28.0,
    this.fontSize = 10.0,
    this.activeFontSize = 12.0,
  }) : super(key: key);

  @override
  State<FancyBottomNavBar> createState() => _FancyBottomNavBarState();
}

class _FancyBottomNavBarState extends State<FancyBottomNavBar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  
  // For ripple effect
  int? _rippleIndex;
  AnimationController? _rippleAnimationController;
  Animation<double>? _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(FancyBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _animationControllers[oldWidget.currentIndex].reverse();
      _animationControllers[widget.currentIndex].forward();
      
      // Create ripple effect
      _createRippleEffect(widget.currentIndex);
    }
  }

  void _initAnimations() {
    // Initialize animation controllers for each item
    _animationControllers = List<AnimationController>.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
        value: index == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    // Initialize animations for each item
    _animations = _animationControllers
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeInBack,
            ))
        .toList();
  }
  
  void _createRippleEffect(int index) {
    // Dispose previous controller if exists
    _rippleAnimationController?.dispose();
    
    // Create new ripple animation
    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimationController!,
        curve: Curves.easeOut,
      ),
    );
    
    setState(() {
      _rippleIndex = index;
    });
    
    _rippleAnimationController!.forward().then((_) {
      if (mounted) {
        setState(() {
          _rippleIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _rippleAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? DesignSystem.primaryColor;
    final activeColor = widget.activeColor ?? DesignSystem.accentColor;
    final inactiveColor = widget.inactiveColor ?? Colors.white.withAlpha(180);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ripple effect layer
          if (_rippleIndex != null && _rippleAnimation != null)
            AnimatedBuilder(
              animation: _rippleAnimation!,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, widget.height),
                  painter: RipplePainter(
                    index: _rippleIndex!,
                    itemCount: widget.items.length,
                    progress: _rippleAnimation!.value,
                    color: activeColor,
                  ),
                );
              },
            ),
          
          // Nav items layer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              return _buildNavItem(
                index: index,
                animation: _animations[index],
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required Animation<double> animation,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isSelected = index == widget.currentIndex;
    
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final iconSize = Tween<double>(
            begin: widget.iconSize,
            end: widget.activeIconSize,
          ).evaluate(animation);
          
          final fontSize = Tween<double>(
            begin: widget.fontSize,
            end: widget.activeFontSize,
          ).evaluate(animation);
          
          final color = ColorTween(
            begin: inactiveColor,
            end: activeColor,
          ).evaluate(animation) ?? inactiveColor;
          
          final textColor = ColorTween(
            begin: inactiveColor,
            end: isSelected ? Colors.white : activeColor,
          ).evaluate(animation) ?? inactiveColor;
          
          final scale = Tween<double>(
            begin: 1.0,
            end: 1.2,
          ).evaluate(animation);
          
          final yOffset = Tween<double>(
            begin: 0.0,
            end: -8.0,
          ).evaluate(animation);
          
          return Container(
            width: MediaQuery.of(context).size.width / widget.items.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: activeColor.withAlpha(100),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.items[index].icon,
                        size: iconSize,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.items[index].label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FancyBottomNavItem {
  final IconData icon;
  final String label;

  const FancyBottomNavItem({
    required this.icon,
    required this.label,
  });
}

class RipplePainter extends CustomPainter {
  final int index;
  final int itemCount;
  final double progress;
  final Color color;

  RipplePainter({
    required this.index,
    required this.itemCount,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final centerX = itemWidth * (index + 0.5);
    final centerY = size.height / 2;
    
    // Calculate max radius to cover the entire nav bar
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final currentRadius = maxRadius * progress;
    
    final paint = Paint()
      ..color = color.withAlpha((50 * (1 - progress)).toInt())
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX, centerY), currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.index != index ||
           oldDelegate.color != color;
  }
}
