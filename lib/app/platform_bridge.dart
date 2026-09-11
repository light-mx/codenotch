import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../notch/notch_geometry.dart';

/// Bridge between Flutter and the macOS native container (NSPanel, NSMenu, NSScreen).
class PlatformBridge {
  static const MethodChannel _channel = MethodChannel('com.codenotch/window');

  final VoidCallback? onRefresh;
  final VoidCallback? onTogglePinned;
  final VoidCallback? onOpenSettings;
  final void Function(int index)? onSignIn;
  final VoidCallback? onScreenChanged;

  PlatformBridge({
    this.onRefresh,
    this.onTogglePinned,
    this.onOpenSettings,
    this.onSignIn,
    this.onScreenChanged,
  }) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRefresh':
        onRefresh?.call();
        return true;
      case 'onTogglePinned':
        onTogglePinned?.call();
        return true;
      case 'onOpenSettings':
        onOpenSettings?.call();
        return true;
      case 'onSignIn':
        final index = call.arguments as int? ?? 0;
        onSignIn?.call(index);
        return true;
      case 'onScreenChanged':
        onScreenChanged?.call();
        return true;
      default:
        return null;
    }
  }

  /// Tells native NSPanel to update its frame.
  Future<void> setWindowFrame(Rect frame) async {
    try {
      await _channel.invokeMethod('setWindowFrame', {
        'x': frame.left,
        'y': frame.top,
        'width': frame.width,
        'height': frame.height,
      });
    } catch (_) {}
  }

  /// Sets interactive hit-test regions so the rest of the transparent panel
  /// passes mouse events through to apps underneath.
  Future<void> setInteractiveRects(List<Rect> rects) async {
    try {
      final data = rects.map((r) => {
        'x': r.left,
        'y': r.top,
        'width': r.width,
        'height': r.height,
      }).toList();
      await _channel.invokeMethod('setInteractiveRects', data);
    } catch (_) {}
  }

  /// Queries the current main screen geometry.
  Future<SimpleScreen?> getScreenGeometry() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getScreenGeometry');
      if (result == null) return null;

      final frameMap = Map<String, dynamic>.from(result['frame'] as Map);
      final visMap = Map<String, dynamic>.from(result['visibleFrame'] as Map);

      final full = Rect.fromLTWH(
        (frameMap['x'] as num).toDouble(),
        (frameMap['y'] as num).toDouble(),
        (frameMap['width'] as num).toDouble(),
        (frameMap['height'] as num).toDouble(),
      );

      final usable = Rect.fromLTWH(
        (visMap['x'] as num).toDouble(),
        (visMap['y'] as num).toDouble(),
        (visMap['width'] as num).toDouble(),
        (visMap['height'] as num).toDouble(),
      );

      HardwareNotch? notch;
      if (result['notch'] != null) {
        final notchMap = Map<String, dynamic>.from(result['notch'] as Map);
        notch = HardwareNotch(
          width: (notchMap['width'] as num).toDouble(),
          height: (notchMap['height'] as num).toDouble(),
        );
      }

      return SimpleScreen(
        frameValue: full,
        visibleFrameValue: usable,
        hardwareNotch: notch,
      );
    } catch (_) {
      return null;
    }
  }

  /// Controls app presence (Dock icon, menu bar status item).
  Future<void> setAppPresence({required bool showInDock, required bool showStatusItem}) async {
    try {
      await _channel.invokeMethod('setAppPresence', {
        'showInDock': showInDock,
        'showStatusItem': showStatusItem,
      });
    } catch (_) {}
  }

  /// Closes or terminates the application.
  Future<void> terminate() async {
    try {
      await _channel.invokeMethod('terminate');
    } catch (_) {}
  }
}
