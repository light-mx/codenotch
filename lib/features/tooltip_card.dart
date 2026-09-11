import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/design.dart';
import '../design_system/palette.dart';
import '../design_system/typography.dart';
import '../model/elapsed_copy.dart';
import '../model/reset_copy.dart';
import '../model/usage_band.dart';
import '../model/usage_model.dart';
import '../notch/notch_edge.dart';
import '../notch/notch_layout.dart';
import '../providers/provider_glyph.dart';
import '../sessions/activity_summary.dart';
import '../sessions/agent_session.dart';

class TooltipTailPainter extends CustomPainter {
  final TooltipDirection direction;
  final Color color;

  const TooltipTailPainter({
    required this.direction,
    this.color = Palette.card,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final Rect rect = Offset.zero & size;

    Offset tip;
    Offset a;
    Offset b;

    switch (direction) {
      case TooltipDirection.leading: // tip on right, pointing back to notch
        tip = Offset(rect.right, rect.center.dy);
        a = Offset(rect.left, rect.top);
        b = Offset(rect.left, rect.bottom);
        break;
      case TooltipDirection.trailing: // tip on left
        tip = Offset(rect.left, rect.center.dy);
        a = Offset(rect.right, rect.top);
        b = Offset(rect.right, rect.bottom);
        break;
      case TooltipDirection.down: // tip on top
        tip = Offset(rect.center.dx, rect.top);
        a = Offset(rect.left, rect.bottom);
        b = Offset(rect.right, rect.bottom);
        break;
      case TooltipDirection.up: // tip on bottom
        tip = Offset(rect.center.dx, rect.bottom);
        a = Offset(rect.left, rect.top);
        b = Offset(rect.right, rect.top);
        break;
    }

    path.moveTo(a.dx, a.dy);
    path.lineTo(tip.dx, tip.dy);
    path.lineTo(b.dx, b.dy);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TooltipTailPainter oldDelegate) =>
      oldDelegate.direction != direction || oldDelegate.color != color;
}

class TooltipShell extends StatelessWidget {
  final double height;
  final TooltipDirection direction;
  final Widget child;

  const TooltipShell({
    super.key,
    required this.height,
    required this.direction,
    required this.child,
  });

  Widget _buildTail() {
    final Size size = (direction == TooltipDirection.leading || direction == TooltipDirection.trailing)
        ? Size(NotchLayout.tailLength, NotchLayout.tailHeight)
        : Size(NotchLayout.tailHeight, NotchLayout.tailLength);

    return CustomPaint(
      size: size,
      painter: TooltipTailPainter(direction: direction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      width: NotchLayout.cardWidth,
      height: height,
      decoration: BoxDecoration(
        color: Palette.card,
        borderRadius: BorderRadius.circular(NotchLayout.cardCorner),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(NotchLayout.cardPadding),
      child: child,
    );

    switch (direction) {
      case TooltipDirection.leading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [cardWidget, _buildTail()],
        );
      case TooltipDirection.trailing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildTail(), cardWidget],
        );
      case TooltipDirection.down:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildTail(), cardWidget],
        );
      case TooltipDirection.up:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [cardWidget, _buildTail()],
        );
    }
  }
}

class SplitRow extends StatelessWidget {
  final String leading;
  final String trailing;
  final Color leadingColor;
  final Color trailingColor;
  final Widget? accessory;

  const SplitRow({
    super.key,
    required this.leading,
    required this.trailing,
    this.leadingColor = Palette.textPrimary,
    this.trailingColor = Palette.textSecondary,
    this.accessory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            leading,
            style: Typography.cardBody.copyWith(color: leadingColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (accessory != null) ...[
          accessory!,
          SizedBox(width: NotchLayout.statusDotGap),
        ],
        Text(
          trailing,
          style: Typography.cardBody.copyWith(color: trailingColor),
          maxLines: 1,
        ),
      ],
    );
  }
}

class StatusRing extends StatefulWidget {
  final AgentSessionState state;
  final Color color;

  const StatusRing({super.key, required this.state, required this.color});

  @override
  State<StatusRing> createState() => _StatusRingState();
}

class _StatusRingState extends State<StatusRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.state == AgentSessionState.busy) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant StatusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AgentSessionState.busy && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.state != AgentSessionState.busy && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = NotchLayout.statusDot;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _StatusRingPainter(
            state: widget.state,
            color: widget.color,
            angle: _controller.value * 2 * math.pi,
          ),
        );
      },
    );
  }
}

class _StatusRingPainter extends CustomPainter {
  final AgentSessionState state;
  final Color color;
  final double angle;

  const _StatusRingPainter({
    required this.state,
    required this.color,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - NotchLayout.statusDotStroke) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = NotchLayout.statusDotStroke;

    switch (state) {
      case AgentSessionState.busy:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          angle - math.pi / 2,
          1.5 * math.pi, // 0.75 trim
          false,
          paint,
        );
        break;
      case AgentSessionState.waiting:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          math.pi, // half ring
          false,
          paint,
        );
        break;
      case AgentSessionState.idle:
        canvas.drawCircle(center, radius, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _StatusRingPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.color != color ||
      oldDelegate.angle != angle;
}

class LimitWindowRow extends StatelessWidget {
  final LimitWindow window;
  final Fidelity fidelity;
  final DateTime now;

  const LimitWindowRow({
    super.key,
    required this.window,
    required this.fidelity,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final band = UsageBand.bandFor(window.usedFraction ?? 0.0);
    final trackWidth = NotchLayout.cardWidth - 2 * NotchLayout.cardPadding;
    final double fraction = (window.usedFraction ?? 0.0).clamp(0.0, 1.0);
    final fillWidth = math.max(NotchLayout.barHeight, trackWidth * fraction);

    final resetText = window.resetsAt != null
        ? ResetCopy.textFor(window.resetsAt!, now: now)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SplitRow(leading: window.label, trailing: resetText),
        if (window.usedFraction != null) ...[
          SizedBox(height: NotchLayout.labelToBar),
          Stack(
            children: [
              Container(
                width: trackWidth,
                height: NotchLayout.barHeight,
                decoration: BoxDecoration(
                  color: Palette.barTrack,
                  borderRadius: BorderRadius.circular(NotchLayout.barHeight / 2),
                ),
              ),
              Container(
                width: fillWidth,
                height: NotchLayout.barHeight,
                decoration: BoxDecoration(
                  color: band.color,
                  borderRadius: BorderRadius.circular(NotchLayout.barHeight / 2),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: NotchLayout.barToUsed),
        Text(
          '${window.usedFraction == null ? '' : fidelity.qualifier}${window.summary}',
          style: Typography.cardBody.copyWith(color: Palette.textPrimary),
        ),
      ],
    );
  }
}

class SessionRow extends StatelessWidget {
  final AgentSession session;
  final DateTime now;

  const SessionRow({super.key, required this.session, required this.now});

  Color get stateColor {
    switch (session.state) {
      case AgentSessionState.busy:
        return Palette.ample;
      case AgentSessionState.waiting:
        return Palette.watch;
      case AgentSessionState.idle:
        return Palette.textSecondary;
    }
  }

  String get stateWord {
    switch (session.state) {
      case AgentSessionState.busy:
        return 'working';
      case AgentSessionState.waiting:
        return 'waiting';
      case AgentSessionState.idle:
        return 'idle';
    }
  }

  String get detail {
    if (session.state == AgentSessionState.waiting &&
        session.waitingFor != null &&
        session.waitingFor!.isNotEmpty) {
      return session.waitingFor!;
    }
    return session.detail;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SplitRow(
          leading: session.name,
          trailing: stateWord,
          trailingColor: stateColor,
          accessory: StatusRing(state: session.state, color: stateColor),
        ),
        SizedBox(height: NotchLayout.sessionRowGap),
        SplitRow(
          leading: detail,
          trailing: ElapsedCopy.text(since: session.since, now: now),
          leadingColor: Palette.textSecondary,
        ),
      ],
    );
  }
}

class TooltipCard extends StatelessWidget {
  final ProviderSnapshot snapshot;
  final ActivitySummary? activity;
  final DateTime now;
  final TooltipDirection direction;
  final int sessionCap;

  const TooltipCard({
    super.key,
    required this.snapshot,
    this.activity,
    required this.now,
    this.direction = TooltipDirection.leading,
    this.sessionCap = NotchLayout.defaultSessionCap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardH = NotchLayout.cardHeight(
      windowCount: snapshot.windows.count,
      sessionCount: activity?.sessions.length ?? 0,
      sessionCap: sessionCap,
      statusMessage: snapshot.statusMessage,
      blockMessage: snapshot.block?.summary(now: now),
    );

    final readingAge = (snapshot.hasReading &&
            snapshot.status.staleSince != null &&
            snapshot.status.staleSince != DateTime.fromMillisecondsSinceEpoch(0))
        ? ElapsedCopy.ago(since: snapshot.status.staleSince!, now: now)
        : null;

    final block = snapshot.block;
    final List<AgentSession> sessions = activity?.sessions ?? [];
    final List<AgentSession> orderedSessions = List.of(sessions)
      ..sort((a, b) {
        int rank(AgentSessionState s) {
          switch (s) {
            case AgentSessionState.waiting:
              return 0;
            case AgentSessionState.busy:
              return 1;
            case AgentSessionState.idle:
              return 2;
          }
        }
        final ra = rank(a.state);
        final rb = rank(b.state);
        return ra == rb ? b.since.compareTo(a.since) : ra.compareTo(rb);
      });

    final shownSessions = orderedSessions.take(sessionCap).toList();
    final hiddenCount = math.max(0, orderedSessions.length - shownSessions.length);

    return TooltipShell(
      height: cardH,
      direction: direction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              ProviderGlyphView(glyph: snapshot.glyph),
              SizedBox(width: NotchLayout.headerGap),
              Text(
                '${snapshot.displayName} Usage',
                style: Typography.cardTitle.copyWith(color: Palette.textPrimary),
              ),
              if (readingAge != null) ...[
                const Spacer(),
                Text(
                  readingAge,
                  style: Typography.cardBody.copyWith(color: Palette.textSecondary),
                ),
              ],
            ],
          ),

          // Blocked notice
          if (block != null) ...[
            SizedBox(height: NotchLayout.headerToBlock),
            Row(
              children: [
                Icon(Icons.pause_circle_filled, size: NotchLayout.statusDot, color: Palette.critical),
                SizedBox(width: NotchLayout.statusDotGap),
                Expanded(
                  child: Text(
                    block.summary(now: now),
                    style: Typography.cardBody.copyWith(color: Palette.critical),
                  ),
                ),
              ],
            ),
          ],

          // Status message or Windows
          if (snapshot.statusMessage != null) ...[
            SizedBox(height: NotchLayout.headerToBlock),
            Text(
              snapshot.statusMessage!,
              style: Typography.cardBody.copyWith(color: Palette.textSecondary),
            ),
          ] else ...[
            for (int i = 0; i < snapshot.windows.length; i++) ...[
              SizedBox(
                height: i == 0 ? NotchLayout.headerToBlock : NotchLayout.blockSpacing,
              ),
              LimitWindowRow(
                window: snapshot.windows[i],
                fidelity: snapshot.fidelity,
                now: now,
              ),
            ],
          ],

          // Live sessions
          if (shownSessions.isNotEmpty) ...[
            SizedBox(height: NotchLayout.blockSpacing),
            Container(
              height: NotchLayout.hairline,
              color: Palette.ringTrack,
            ),
            for (final session in shownSessions) ...[
              SizedBox(height: NotchLayout.blockSpacing),
              SessionRow(session: session, now: now),
            ],
            if (hiddenCount > 0) ...[
              SizedBox(height: NotchLayout.blockSpacing),
              Text(
                'and $hiddenCount more',
                style: Typography.cardBody.copyWith(color: Palette.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
