import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/controllers/theme_controller.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final SplashController _controller = SplashController();
  late AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _controller.init(this, context);
    _loopController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    final List<Color> bgColors = isDark
        ? [const Color(0xFF0A0A0A), const Color(0xFF1A1625), const Color(0xFF0F1419)]
        : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0), const Color(0xFFF1F5F9)];

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _loopController,
            builder: (context, _) => CustomPaint(
              painter: _AmbientEffectsPainter(_loopController.value, isDark),
              size: Size.infinite,
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller.mainController,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _controller.scaleAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: AppTheme.teal.withOpacity(0.3), blurRadius: 60, spreadRadius: 10),
                                BoxShadow(color: AppTheme.violet.withOpacity(0.2), blurRadius: 80, spreadRadius: 20),
                              ],
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _loopController,
                            builder: (context, _) => Transform.translate(
                              offset: Offset(0, sin(_loopController.value * pi * 4) * -5),
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: CustomPaint(painter: _SmartChecklistPainter(isDark)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Transform.translate(
                      offset: Offset(0, _controller.slideAnimation.value),
                      child: Opacity(
                        opacity: _controller.fadeAnimation.value,
                        child: Column(
                          children: [
                            const Text(
                              'Smart Task',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.teal,
                                letterSpacing: -1,
                                shadows: [Shadow(color: AppTheme.teal, blurRadius: 20)],
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppTheme.teal, AppTheme.violet, AppTheme.amber],
                              ).createShader(bounds),
                              child: Text(
                                'Management',
                                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -1),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'PREMIUM PRODUCTIVITY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                                color: AppTheme.violet.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _LoadingDot(color: AppTheme.teal, delay: 0, controller: _loopController),
                                _LoadingDot(color: AppTheme.violet, delay: 0.33, controller: _loopController),
                                _LoadingDot(color: AppTheme.amber, delay: 0.66, controller: _loopController),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDot extends StatelessWidget {
  final Color color;
  final double delay;
  final AnimationController controller;

  const _LoadingDot({required this.color, required this.delay, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + delay) % 1.0;
        final scale = 1.0 + sin(progress * pi * 2) * 0.5;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)],
          ),
          transform: Matrix4.identity()..scale(scale, scale),
        );
      },
    );
  }
}

class _SmartChecklistPainter extends CustomPainter {
  final bool isDark;
  _SmartChecklistPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final rectPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.teal, AppTheme.violet, AppTheme.amber],
      ).createShader(Rect.fromLTWH(30, 20, 60, 80))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 20, 60, 80), const Radius.circular(6)), rectPaint);

    final aiPaint = Paint()..style = PaintingStyle.fill;
    aiPaint.color = AppTheme.teal.withOpacity(0.8);
    canvas.drawCircle(const Offset(60, 30), 4, aiPaint);
    aiPaint.color = AppTheme.amber;
    canvas.drawCircle(const Offset(60, 30), 2, aiPaint);

    _drawItem(canvas, 45, AppTheme.teal, true);
    _drawItem(canvas, 62, AppTheme.violet, true);
    _drawItem(canvas, 79, AppTheme.amber, false);
  }

  void _drawItem(Canvas canvas, double y, Color color, bool isCompleted) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(40, y, 10, 10), const Radius.circular(2)), paint);

    if (isCompleted) {
      final path = Path()..moveTo(42, y + 5)..lineTo(45, y + 8)..lineTo(48, y + 2);
      canvas.drawPath(path, paint);
      paint.strokeWidth = 1.5;
      paint.color = color.withOpacity(0.6);
      canvas.drawLine(Offset(55, y + 5), Offset(75, y + 5), paint);
    } else {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(45, y + 5), 1.5, paint);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;
      paint.color = color.withOpacity(0.5);
      canvas.drawLine(Offset(55, y + 5), Offset(78, y + 5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AmbientEffectsPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _AmbientEffectsPainter(this.progress, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.5;

    final double opacityMulti = isDark ? 0.2 : 0.05;

    paint.color = AppTheme.violet.withOpacity(opacityMulti);
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2), paint);
    paint.color = AppTheme.amber.withOpacity(opacityMulti);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.8), paint);
    paint.color = AppTheme.teal.withOpacity(opacityMulti);
    canvas.drawLine(Offset(size.width * 0.15, 0), Offset(size.width * 0.15, size.height), paint);
    paint.color = AppTheme.violet.withOpacity(opacityMulti);
    canvas.drawLine(Offset(size.width * 0.85, 0), Offset(size.width * 0.85, size.height), paint);

    _drawParticle(canvas, size, 0.2, 0.8, AppTheme.violet, 3, 0.0);
    _drawParticle(canvas, size, 0.75, 0.7, AppTheme.teal, 4, 0.2);
    _drawParticle(canvas, size, 0.45, 0.75, AppTheme.amber, 2, 0.5);
    _drawParticle(canvas, size, 0.8, 0.55, AppTheme.amber, 3, 0.8);
  }

  void _drawParticle(Canvas canvas, Size size, double nx, double ny, Color color, double r, double delay) {
    final p = (progress + delay) % 1.0;
    final yOffset = sin(p * pi * 2) * 50;
    final alpha = (sin(p * pi) * (isDark ? 255 : 150)).toInt().clamp(0, 255);
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(size.width * nx, (size.height * ny) + yOffset), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}