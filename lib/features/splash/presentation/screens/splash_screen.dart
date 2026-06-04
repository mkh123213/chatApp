import 'dart:math' as math;

import 'package:chat_material3/constants/app_images.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _shimmerController;
  late final AnimationController _particleController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.repeat();
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    _shimmerController.repeat();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    _navigateNext();
  }

  void _navigateNext() {
    final isLoggedIn = SharedPref().getString(PrefKeys.currentUser) != null;
    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? AppRoutes.mainScreen : AppRoutes.logIn,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Color(0xFF533483),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlePainter(_particleController.value),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Transform.rotate(
                            angle: _logoRotation.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE94560).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: const Color(0xFF533483).withValues(alpha: 0.3),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          Assets.assetsImagesCoreSplash,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: Listenable.merge([_textController, _shimmerController]),
                    builder: (context, _) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment(_shimmerAnimation.value - 1, 0),
                                end: Alignment(_shimmerAnimation.value, 0),
                                colors: const [
                                  Colors.white,
                                  Color(0xFFFFD700),
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'ALKHATEEB CHAT',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _textOpacity.value * 0.6,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value * 0.5),
                          child: const Text(
                            'Connect. Chat. Share.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final y = (baseY - progress * speed * size.height) % size.height;
      final radius = 1.0 + random.nextDouble() * 2.5;
      final opacity = 0.1 + random.nextDouble() * 0.3;

      paint.color = Color.lerp(
        const Color(0xFFE94560),
        const Color(0xFF533483),
        random.nextDouble(),
      )!.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
