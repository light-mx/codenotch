import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Example showing how Flutter communicates interactive hit-test regions
/// to a transparent native desktop window (NSPanel).
class WindowBridge {
  static const MethodChannel _channel = MethodChannel('com.example.app/window');

  /// Informs macOS NSPanel about regions where mouse clicks must be captured.
  /// Any clicks outside these rectangles pass through to apps below!
  static Future<void> updateInteractiveRects(List<Rect> rects) async {
    try {
      final List<Map<String, double>> payload = rects.map((r) => {
        'x': r.left,
        'y': r.top,
        'width': r.width,
        'height': r.height,
      }).toList();

      await _channel.invokeMethod('setInteractiveRects', payload);
    } on PlatformException catch (e) {
      debugPrint('Failed to set interactive rects: ${e.message}');
    }
  }

  /// Repositions the native window frame.
  static Future<void> setWindowFrame(Rect frame) async {
    try {
      await _channel.invokeMethod('setWindowFrame', {
        'x': frame.left,
        'y': frame.top,
        'width': frame.width,
        'height': frame.height,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to set window frame: ${e.message}');
    }
  }
}
