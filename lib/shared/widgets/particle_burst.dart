import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBurst extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const ParticleBurst({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<ParticleBurst> createState() => ParticleBurstState();
}

class ParticleBurstState extends State<ParticleBurst> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _particles.clear());
        widget.onComplete?.call();
      }
    });
  }

  void burst() {
    setState(() {
      _particles.clear();
      for (int i = 0; i < 15; i++) {
        _particles.add(_Particle(
          angle: _random.nextDouble() * 2 * pi,
          distance: _random.nextDouble() * 60 + 20,
          size: _random.nextDouble() * 6 + 2,
          color: Colors.amber.withOpacity(_random.nextDouble() * 0.5 + 0.5),
        ));
      }
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentDist = particle.distance * progress;
      final x = center.dx + cos(particle.angle) * currentDist;
      final y = center.dy + sin(particle.angle) * currentDist;
      
      paint.color = particle.color.withOpacity(1 - progress);
      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
