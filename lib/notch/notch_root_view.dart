import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/design.dart';
import '../design_system/palette.dart';
import '../features/provider_ring.dart';
import '../features/settings_handle.dart';
import '../features/tooltip_card.dart';
import '../model/usage_model.dart';
import 'notch_edge.dart';
import 'notch_layout.dart';
import 'notch_motion.dart';
import 'notch_placement.dart';
import 'notch_view_model.dart';
import 'side_notch_painter.dart';

class NotchRootView extends StatefulWidget {
  final NotchViewModel model;
  final VoidCallback? onOpenSettings;
  final void Function(String id)? onRefreshProvider;

  const NotchRootView({
    super.key,
    required this.model,
    this.onOpenSettings,
    this.onRefreshProvider,
  });

  @override
  State<NotchRootView> createState() => _NotchRootViewState();
}

class _NotchRootViewState extends State<NotchRootView> {
  Timer? _foldTimer;
  Timer? _clearHoverTimer;

  static const Duration _hoverGrace = Duration(milliseconds: 250);
  static const Duration _foldGrace = Duration(milliseconds: 450);

  @override
  void dispose() {
    _foldTimer?.cancel();
    _clearHoverTimer?.cancel();
    super.dispose();
  }

  void _onPointerHover(PointerHoverEvent event, NotchPlacement place) {
    final model = widget.model;
    final Offset local = event.localPosition;

    // Check if over live rect
    final along = place.alongOf(local);
    final across = place.acrossOf(local);

    final bool overNotch = model.isExpanded
        ? (along >= model.slackValue &&
            along <= model.slackValue + model.shapeLengthValue &&
            across >= 0 &&
            across <= model.notchDepth)
        : (along >= model.notchLeadingInset - NotchLayout.pillHotZone / 2 &&
            along <= model.notchLeadingInset + model.restingLength + NotchLayout.pillHotZone / 2 &&
            across >= 0 &&
            across <= model.restingDepth + NotchLayout.pillHotZone);

    final bool overHandle = model.isExpanded &&
        model.isOnOrbHandle(
          along: along - model.slackValue,
          across: across,
        );

    model.setHoveringSettings(overHandle);

    if (overNotch || overHandle) {
      _foldTimer?.cancel();
      _foldTimer = null;
      if (!model.isExpanded) {
        model.setExpanded(true);
      }
    } else {
      if (model.isExpanded && !model.staysOpen && _foldTimer == null) {
        _foldTimer = Timer(_foldGrace, () {
          if (!mounted) return;
          if (!model.staysOpen) {
            model.setExpanded(false);
            model.setHoveredIndex(null);
          }
        });
      }
    }

    // Check which cell is hovered
    if (model.isExpanded && overNotch) {
      int? target;
      final pitch = NotchLayout.cellPitch(model.edge);
      for (int i = 0; i < model.snapshots.length; i++) {
        final center = model.slackValue + model.ringCenter(i);
        if ((along - center).abs() <= pitch / 2) {
          target = i;
          break;
        }
      }

      if (target != null) {
        _clearHoverTimer?.cancel();
        _clearHoverTimer = null;
        model.setHoveredIndex(target);
      }
    } else if (model.hoveredIndex != null && _clearHoverTimer == null) {
      _clearHoverTimer = Timer(_hoverGrace, () {
        if (!mounted) return;
        model.setHoveredIndex(null);
      });
    }
  }

  void _handleClick(NotchPlacement place, Offset local) {
    final model = widget.model;
    if (!model.isExpanded) {
      model.setExpanded(true);
      return;
    }

    final along = place.alongOf(local);
    final across = place.acrossOf(local);

    if (model.isOnOrbHandle(along: along - model.slackValue, across: across)) {
      widget.onOpenSettings?.call();
      return;
    }

    final pitch = NotchLayout.cellPitch(model.edge);
    for (int i = 0; i < model.snapshots.length; i++) {
      final center = model.slackValue + model.ringCenter(i);
      if ((along - center).abs() <= pitch / 2) {
        widget.onRefreshProvider?.call(model.snapshots[i].id);
        return;
      }
    }

    model.togglePinned();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, child) {
        final model = widget.model;

        return LayoutBuilder(
          builder: (context, constraints) {
            final panelSize = Size(constraints.maxWidth, constraints.maxHeight);
            final place = NotchPlacement(edge: model.edge, panelSize: panelSize);

            return MouseRegion(
              onHover: (e) => _onPointerHover(e, place),
              child: GestureDetector(
                onTapUp: (details) => _handleClick(place, details.localPosition),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // --- Notch Body ---
                    _buildNotchBody(place),

                    // --- Settings Orb ---
                    if (model.snapshots.isNotEmpty) _buildSettingsOrb(place),

                    // --- Tooltip Card ---
                    if (model.hoveredSnapshot != null &&
                        model.hoveredIndex != null &&
                        model.isExpanded)
                      _buildTooltip(place, model.hoveredIndex!, model.hoveredSnapshot!),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotchBody(NotchPlacement place) {
    final model = widget.model;
    final size = model.notchSize;
    final center = place.point(
      along: model.notchLeadingInset + model.notchLength / 2,
      across: model.notchDepth / 2,
    );

    return Positioned(
      left: center.dx - size.width / 2,
      top: center.dy - size.height / 2,
      child: AnimatedContainer(
        duration: NotchMotion.unfoldDuration,
        curve: NotchMotion.unfoldCurve,
        width: size.width,
        height: size.height,
        child: ClipPath(
          clipper: SideNotchClipper(edge: model.edge, joining: model.joinedNotch),
          child: CustomPaint(
            painter: SideNotchPainter(edge: model.edge, joining: model.joinedNotch),
            child: _buildCells(size),
          ),
        ),
      ),
    );
  }

  Widget _buildCells(Size notchSize) {
    final model = widget.model;
    final double leadIn = model.flare +
        NotchLayout.padStart(model.edge) +
        model.endSpread;

    final cellWidgets = <Widget>[];
    for (int i = 0; i < model.snapshots.length; i++) {
      final snapshot = model.snapshots[i];
      final activity = model.activityFor(snapshot.id);
      final isRefreshing = model.refreshing.contains(snapshot.id);

      cellWidgets.add(
        AnimatedOpacity(
          opacity: model.isExpanded ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200 + i * 40),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: model.isExpanded
                ? Offset.zero
                : Offset(model.edge.outward.dx * 0.4, model.edge.outward.dy * 0.4),
            duration: Duration(milliseconds: 250 + i * 40),
            curve: Curves.easeOutBack,
            child: SizedBox(
              width: model.edge.isVertical ? null : NotchLayout.cellAlong(model.edge),
              child: ProviderCell(
                snapshot: snapshot,
                activity: activity,
                isRefreshing: isRefreshing,
              ),
            ),
          ),
        ),
      );
    }

    if (model.edge.isVertical) {
      return Padding(
        padding: EdgeInsets.only(top: leadIn),
        child: SizedBox(
          width: NotchLayout.bodyDepth(model.edge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < cellWidgets.length; i++) ...[
                if (i > 0) SizedBox(height: NotchLayout.cellSpacing),
                cellWidgets[i],
              ],
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: leadIn),
        child: SizedBox(
          height: NotchLayout.bodyDepth(model.edge),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < cellWidgets.length; i++) ...[
                if (i > 0) SizedBox(width: NotchLayout.cellSpacing),
                cellWidgets[i],
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSettingsOrb(NotchPlacement place) {
    final model = widget.model;
    final orbCenter = place.point(
      along: model.slackValue + model.orbAlong,
      across: model.orbInset,
    );

    final radius = model.orbArcRadius;
    final frameSize = radius * 2 + NotchLayout.orbStroke;

    return Positioned(
      left: orbCenter.dx - frameSize / 2,
      top: orbCenter.dy - frameSize / 2,
      child: AnimatedOpacity(
        opacity: model.isExpanded ? 1.0 : 0.0,
        duration: NotchMotion.crossfadeDuration,
        child: AnimatedScale(
          scale: model.isExpanded ? 1.0 : model.orbMergeScale,
          duration: NotchMotion.mergeDuration,
          curve: Curves.easeIn,
          child: SettingsOrb(
            isHovered: model.isHoveringSettings,
            edge: model.edge,
            convex: model.orbHugsCorner,
            arcRadius: model.orbArcRadius,
            arcOffset: model.orbArcOffset,
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(NotchPlacement place, int index, ProviderSnapshot snapshot) {
    final model = widget.model;
    final activity = model.activityFor(snapshot.id);

    final double cardAcross = model.edge.isVertical
        ? NotchLayout.cardWidth
        : NotchLayout.cardHeight(
            windowCount: snapshot.windows.length,
            sessionCount: activity?.sessions.length ?? 0,
            sessionCap: model.sessionCap,
            statusMessage: snapshot.statusMessage,
            blockMessage: snapshot.block?.summary(now: model.now),
          );

    final center = place.point(
      along: model.slackValue + model.ringCenter(index),
      across: model.contentInset + (NotchLayout.tailLength + cardAcross) / 2 + NotchLayout.tailGap,
    );

    return Positioned(
      left: center.dx - NotchLayout.cardWidth / 2,
      top: center.dy - cardAcross / 2,
      child: TooltipCard(
        snapshot: snapshot,
        activity: activity,
        now: model.now,
        direction: model.edge.tooltipDirection,
        sessionCap: model.sessionCap,
      ),
    );
  }
}
