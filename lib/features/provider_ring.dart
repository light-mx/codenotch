import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/palette.dart';
import '../design_system/typography.dart';
import '../model/usage_band.dart';
import '../model/usage_model.dart';
import '../notch/notch_layout.dart';
import '../providers/provider_glyph.dart';
import '../sessions/activity_summary.dart';

class ProviderRingPainter extends CustomPainter {
  final double? usedFraction;
  final UsageBand band;
  final bool isBlocked;
  final double spinDegrees;

  const ProviderRingPainter({
    required this.usedFraction,
    required this.band,
    required this.isBlocked,
    required this.spinDegrees,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track stroke
    final trackPaint = Paint()
      ..color = Palette.ringTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = NotchLayout.trackStroke;
    canvas.drawCircle(center, radius - NotchLayout.trackStroke / 2, trackPaint);

    // Progress arc
    if (usedFraction != null) {
      final double sweep = usedFraction!.clamp(0.0, 1.0);
      final progressPaint = Paint()
        ..color = band.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = NotchLayout.progressStroke;

      final double startAngle = (-math.pi / 2) + (spinDegrees * math.pi / 180);
      final double sweepAngle = 2 * math.pi * sweep;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - NotchLayout.trackStroke / 2),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProviderRingPainter oldDelegate) =>
      oldDelegate.usedFraction != usedFraction ||
      oldDelegate.band != band ||
      oldDelegate.isBlocked != isBlocked ||
      oldDelegate.spinDegrees != spinDegrees;
}

class ActivityArc extends StatefulWidget {
  final ActivitySummary summary;

  const ActivityArc({super.key, required this.summary});

  @override
  State<ActivityArc> createState() => _ActivityArcState();
}

class _ActivityArcState extends State<ActivityArc> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant ActivityArc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summary.state == ActivityState.waiting) {
      _controller.duration = const Duration(milliseconds: 900);
    } else {
      _controller.duration = const Duration(milliseconds: 1100);
    }
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
        if (widget.summary.state == ActivityState.idle) return const SizedBox.shrink();

        final center = Offset(NotchLayout.ringDiameter / 2, NotchLayout.ringDiameter / 2);
        final radius = NotchLayout.activityDiameter / 2;

        if (widget.summary.state == ActivityState.working) {
          return CustomPaint(
            size: Size(NotchLayout.ringDiameter, NotchLayout.ringDiameter),
            painter: _SpinnerArcPainter(
              color: widget.summary.color,
              radius: radius,
              center: center,
              angle: _controller.value * 2 * math.pi,
            ),
          );
        } else {
          final double opacity = 0.3 + 0.7 * ((math.sin(_controller.value * 2 * math.pi) + 1) / 2);
          return Opacity(
            opacity: opacity,
            child: CustomPaint(
              size: Size(NotchLayout.ringDiameter, NotchLayout.ringDiameter),
              painter: _PulseArcPainter(
                color: widget.summary.color,
                radius: radius,
                center: center,
              ),
            ),
          );
        }
      },
    );
  }
}

class _SpinnerArcPainter extends CustomPainter {
  final Color color;
  final double radius;
  final Offset center;
  final double angle;

  const _SpinnerArcPainter({
    required this.color,
    required this.radius,
    required this.center,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NotchLayout.activityStroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      angle - math.pi / 2,
      math.pi / 2, // 25% of circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerArcPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color;
}

class _PulseArcPainter extends CustomPainter {
  final Color color;
  final double radius;
  final Offset center;

  const _PulseArcPainter({
    required this.color,
    required this.radius,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = NotchLayout.activityStroke;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseArcPainter oldDelegate) => oldDelegate.color != color;
}

class ProviderRing extends StatefulWidget {
  final double? usedFraction;
  final ProviderGlyph glyph;
  final bool isStale;
  final bool isBlocked;
  final ActivitySummary? activity;
  final bool isRefreshing;

  const ProviderRing({
    super.key,
    this.usedFraction,
    required this.glyph,
    this.isStale = false,
    this.isBlocked = false,
    this.activity,
    this.isRefreshing = false,
  });

  @override
  State<ProviderRing> createState() => _ProviderRingState();
}

class _ProviderRingState extends State<ProviderRing> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
  }

  @override
  void didUpdateWidget(covariant ProviderRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !oldWidget.isRefreshing) {
      _spinController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  UsageBand get band =>
      widget.isBlocked ? UsageBand.exhausted : UsageBand.bandFor(widget.usedFraction ?? 0.0);

  @override
  Widget build(BuildContext context) {
    final double size = NotchLayout.ringDiameter;

    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        final double spinDegrees = CurvedAnimation(
          parent: _spinController,
          curve: Curves.easeOutCubic,
        ).value * 360;

        return AnimatedScale(
          scale: widget.isRefreshing ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: widget.isStale ? 0.45 : 1.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: ProviderRingPainter(
                          usedFraction: widget.usedFraction,
                          band: band,
                          isBlocked: widget.isBlocked,
                          spinDegrees: spinDegrees,
                        ),
                      ),
                      Opacity(
                        opacity: band == UsageBand.exhausted ? 0.35 : 1.0,
                        child: ProviderGlyphView(glyph: widget.glyph),
                      ),
                    ],
                  ),
                ),
                if (widget.activity != null && widget.activity!.state != ActivityState.idle)
                  ActivityArc(summary: widget.activity!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProviderCell extends StatelessWidget {
  final ProviderSnapshot snapshot;
  final ActivitySummary? activity;
  final bool isRefreshing;

  const ProviderCell({
    super.key,
    required this.snapshot,
    this.activity,
    this.isRefreshing = false,
  });

  String get percentText => snapshot.hasReading ? snapshot.headlineText : '—';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NotchLayout.cellExtent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProviderRing(
            usedFraction: snapshot.hasReading ? snapshot.ringFraction : null,
            glyph: snapshot.glyph,
            isStale: snapshot.status.isStale || !snapshot.hasReading,
            isBlocked: snapshot.block != null,
            activity: activity,
            isRefreshing: isRefreshing,
          ),
          SizedBox(height: NotchLayout.ringLabelGap),
          SizedBox(
            height: NotchLayout.percentLineHeight,
            child: Text(
              percentText,
              style: Typography.percent.copyWith(color: Palette.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
