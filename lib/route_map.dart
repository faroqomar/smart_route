import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'route_plan.dart';

const _forest = Color(0xff202e27);
const _lime = Color(0xffd2f579);

class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.stops});

  final List<RouteStop> stops;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Schematic map of Merter. Starts at ${departure.name}.',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 232,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey(stops.map((stop) => stop.name).join('|')),
                tween: Tween(begin: 0, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 580),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) =>
                    CustomPaint(painter: _MapPainter(stops, progress)),
              ),
              const Positioned(
                left: 15,
                top: 13,
                child: _MapTag('MERTER, ISTANBUL'),
              ),
              const Positioned(
                right: 16,
                top: 14,
                child: Column(
                  children: [
                    Text(
                      'N',
                      style: TextStyle(
                        color: Color(0xffdcdfcf),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.navigation_outlined,
                      size: 15,
                      color: Color(0xffdcdfcf),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 15,
                bottom: 13,
                child: _MapTag('SCHEMATIC MAP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapTag extends StatelessWidget {
  const _MapTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff23302a),
        border: Border.all(color: const Color(0xff49564a)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xffeceddd),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.15,
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.stops, this.progress);

  final List<RouteStop> stops;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = _forest);
    _drawDistrict(canvas, size);

    final points = [
      _position(departure, size),
      for (final stop in stops) _position(stop, size),
    ];

    if (stops.isNotEmpty) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      final metric = path.computeMetrics().first;
      final trace = metric.extractPath(0, metric.length * progress);
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(
        trace,
        line
          ..color = const Color(0xff132219)
          ..strokeWidth = 8,
      );
      canvas.drawPath(
        trace,
        line
          ..color = _lime
          ..strokeWidth = 2.8,
      );
    }

    _drawOrigin(canvas, points.first);
    for (var index = 1; index < points.length; index++) {
      _drawStop(canvas, points[index], index);
    }
  }

  Offset _position(RouteStop stop, Size size) => Offset(
    13 + stop.eastKm / 4.4 * (size.width - 26),
    27 + (1 - stop.northKm / 2.8) * (size.height - 51),
  );

  void _drawDistrict(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.save();
    canvas.clipRect(bounds);

    final block = Paint();
    const blocks = [
      Color(0xff293a30),
      Color(0xff2e3d32),
      Color(0xff26372e),
      Color(0xff314034),
    ];
    canvas.save();
    canvas.translate(-45, -48);
    canvas.rotate(-0.31);
    final extent = size.width + size.height;
    for (var row = 0; row < 10; row++) {
      for (var left = -42.0, column = 0; left < extent; column++) {
        final width = 25.0 + ((column * 11 + row * 7) % 28);
        final top = row * 32.0 + 54;
        final rect = Rect.fromLTWH(left, top, width, 25);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          block..color = blocks[(column + row * 3) % blocks.length],
        );
        left += width + 5;
      }
    }
    canvas.restore();

    final streets = [
      Path()
        ..moveTo(-10, size.height * .36)
        ..cubicTo(
          size.width * .30,
          size.height * .29,
          size.width * .52,
          size.height * .66,
          size.width + 10,
          size.height * .40,
        ),
      Path()
        ..moveTo(size.width * .15, -10)
        ..cubicTo(
          size.width * .21,
          size.height * .39,
          size.width * .57,
          size.height * .25,
          size.width * .70,
          size.height + 10,
        ),
      Path()
        ..moveTo(-10, size.height * .85)
        ..lineTo(size.width * .24, size.height * .76)
        ..quadraticBezierTo(
          size.width * .64,
          size.height * .72,
          size.width + 10,
          size.height * .84,
        ),
      Path()
        ..moveTo(size.width * .81, -10)
        ..quadraticBezierTo(
          size.width * .84,
          size.height * .36,
          size.width * .97,
          size.height + 10,
        ),
    ];
    final street = Paint()..style = PaintingStyle.stroke;
    for (final path in streets) {
      canvas.drawPath(
        path,
        street
          ..color = _forest
          ..strokeWidth = 9,
      );
      canvas.drawPath(
        path,
        street
          ..color = const Color(0xff475447)
          ..strokeWidth = 3,
      );
    }

    final dot = Paint()..color = const Color(0xff637062).withValues(alpha: .35);
    for (var x = 8.0; x < size.width; x += 12) {
      for (var y = 7.0; y < size.height; y += 12) {
        canvas.drawCircle(Offset(x, y), .5, dot);
      }
    }

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x70202e27), Color(0x00202e27), Color(0x50202e27)],
          stops: [0, .53, 1],
        ).createShader(bounds),
    );
    canvas.restore();
  }

  void _drawOrigin(Canvas canvas, Offset position) {
    canvas.drawCircle(position, 15, Paint()..color = const Color(0xff132219));
    canvas.drawCircle(position, 12, Paint()..color = const Color(0xfffaf6e9));
    final arrow = Path()
      ..moveTo(position.dx + 4, position.dy - 5)
      ..lineTo(position.dx + 1, position.dy + 5)
      ..lineTo(position.dx - 1, position.dy + 1)
      ..lineTo(position.dx - 5, position.dy - 1)
      ..close();
    canvas.drawPath(arrow, Paint()..color = _forest);
  }

  void _drawStop(Canvas canvas, Offset position, int number) {
    final radius = math.min(12.0, 10.0 + progress * 2);
    canvas.drawCircle(
      position,
      radius + 2.5,
      Paint()..color = const Color(0xff132219),
    );
    canvas.drawCircle(position, radius, Paint()..color = _lime);
    final label = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          fontSize: 12,
          color: _forest,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, position - Offset(label.width / 2, label.height / 2));
    label.dispose();
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.stops != stops || oldDelegate.progress != progress;
}
