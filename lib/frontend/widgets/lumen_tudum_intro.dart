import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen/frontend/theme/app_theme.dart';

/// Animação de introdução cinematográfica estilo "Tudum" da Netflix.
/// O logo Lúmen irradia uma aura de luz âmbar pulsante e dissolve para a Home.
class LumenTudumIntro extends StatefulWidget {
  const LumenTudumIntro({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<LumenTudumIntro> createState() => _LumenTudumIntroState();
}

class _LumenTudumIntroState extends State<LumenTudumIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Efeito de impacto tátil
    HapticFeedback.heavyImpact();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 30,
      ),
    ]).animate(_controller);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.8),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lumen;

    return Scaffold(
      backgroundColor: colors.bg,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Pulso radial de luz âmbar de fundo
                Center(
                  child: Container(
                    width: 380 * _glowAnimation.value,
                    height: 380 * _glowAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accent.withAlpha(
                            (120 * _glowAnimation.value.clamp(0.0, 1.0)).toInt(),
                          ),
                          colors.accent.withAlpha(20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Logo Lúmen com efeito de escala
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.accent,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.accent.withAlpha(180),
                                blurRadius: 36 * _glowAnimation.value,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            size: 48,
                            color: colors.accent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Lúmen',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: colors.accent.withAlpha(140),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
