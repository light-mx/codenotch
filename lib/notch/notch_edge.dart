import 'package:flutter/material.dart';

/// Where the tooltip goes: away from the bezel, always.
enum TooltipDirection {
  leading, // card to the left of the notch
  trailing, // card to the right of it
  up, // card above it
  down, // card below it
}

/// Which screen edge the notch is welded to.
enum NotchEdge {
  right('Right', 'Down the right-hand edge, clear of a Dock on that side.'),
  left('Left', 'Down the left-hand edge, clear of a Dock on that side.'),
  top(
    'Top',
    'A wide bar across the top, readings side by side. On a Mac with a notch of its own it runs up to meet it, so the two read as one shape.',
  ),
  bottom('Bottom', 'A wide bar resting on top of the Dock, readings side by side.');

  final String title;
  final String explanation;

  const NotchEdge(this.title, this.explanation);

  bool get isVertical => this == NotchEdge.right || this == NotchEdge.left;

  TooltipDirection get tooltipDirection {
    switch (this) {
      case NotchEdge.right:
        return TooltipDirection.leading;
      case NotchEdge.left:
        return TooltipDirection.trailing;
      case NotchEdge.top:
        return TooltipDirection.down;
      case NotchEdge.bottom:
        return TooltipDirection.up;
    }
  }

  /// A unit vector pointing at the bezel in panel coordinates (y grows down).
  Offset get outward {
    switch (this) {
      case NotchEdge.right:
        return const Offset(1, 0);
      case NotchEdge.left:
        return const Offset(-1, 0);
      case NotchEdge.top:
        return const Offset(0, -1);
      case NotchEdge.bottom:
        return const Offset(0, 1);
    }
  }

  Offset get alongDirection => isVertical ? const Offset(0, 1) : const Offset(1, 0);
}
