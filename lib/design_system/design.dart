/// Every number in this app's UI is measured off the Figma frame in
/// `docs/design/frame-124-hover-tooltip.png` (2000 x 2000 px), so the layout is
/// *proportionally* exact rather than eyeballed.
///
/// The frame fixes only ratios, never an absolute size, so one anchor picks the
/// scale: the design spec calls the provider ring 44pt across, and it measures
/// 117px in the frame. Change `scale` and the whole surface — notch, rings,
/// type, tooltip — resizes together, still in the design's proportions.
abstract final class Design {
  /// Points per pixel of the design frame.
  static const double scale = 44.0 / 117.0;

  /// A distance measured in design-frame pixels, in points.
  static double px(double pixels) => pixels * scale;

  /// Cap-height fraction of an em for SF Pro. Text in the frame can only be
  /// measured by its cap height, so this converts back to a point size.
  static const double capRatio = 0.714;

  /// The point size whose capital letters are `pixels` tall in the frame.
  static double fontSize({required double capPixels}) {
    return px(capPixels) / capRatio;
  }
}
