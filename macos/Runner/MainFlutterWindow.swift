import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSPanel {
    private var channel: FlutterMethodChannel?
    var interactiveRects: [NSRect] = []

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.isMovable = false
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false
        self.becomesKeyOnlyIfNeeded = true
        self.isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        let registrar = flutterViewController.registrar(forPlugin: "WindowPlugin")
        let channel = FlutterMethodChannel(
            name: "com.codenotch/window",
            binaryMessenger: registrar.messenger
        )
        self.channel = channel

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "setWindowFrame":
                if let args = call.arguments as? [String: Double],
                   let x = args["x"], let y = args["y"],
                   let width = args["width"], let height = args["height"] {
                    let screenHeight = NSScreen.main?.frame.height ?? 1080
                    let appKitY = screenHeight - y - height
                    self.setFrame(NSRect(x: x, y: appKitY, width: width, height: height), display: true)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                }
            case "setInteractiveRects":
                if let rectsData = call.arguments as? [[String: Double]] {
                    self.interactiveRects = rectsData.compactMap { r in
                        guard let x = r["x"], let y = r["y"], let w = r["width"], let h = r["height"] else { return nil }
                        return NSRect(x: x, y: y, width: w, height: h)
                    }
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
                }
            case "getScreenGeometry":
                if let screen = NSScreen.main {
                    let full = screen.frame
                    let usable = screen.visibleFrame
                    let screenHeight = full.height
                    var res: [String: Any] = [
                        "frame": [
                            "x": full.origin.x,
                            "y": screenHeight - full.maxY,
                            "width": full.width,
                            "height": full.height
                        ],
                        "visibleFrame": [
                            "x": usable.origin.x,
                            "y": screenHeight - usable.maxY,
                            "width": usable.width,
                            "height": usable.height
                        ]
                    ]
                    if #available(macOS 12.0, *) {
                        let topArea = screen.safeAreaInsets.top
                        if topArea > 0 {
                            res["notch"] = ["width": 200.0, "height": Double(topArea)]
                        }
                    }
                    result(res)
                } else {
                    result(nil)
                }
            case "terminate":
                NSApplication.shared.terminate(nil)
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .rightMouseDown {
            let localPoint = event.locationInWindow
            let flippedPoint = NSPoint(x: localPoint.x, y: self.frame.height - localPoint.y)
            if interactiveRects.contains(where: { $0.contains(flippedPoint) }) {
                showContextMenu(with: event)
                return
            }
        }
        super.sendEvent(event)
    }

    private func showContextMenu(with event: NSEvent) {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let pinItem = NSMenuItem(title: "Keep open", action: #selector(togglePinnedAction), keyEquivalent: "")
        pinItem.target = self
        menu.addItem(pinItem)
        menu.addItem(NSMenuItem.separator())

        let refreshItem = NSMenuItem(title: "Refresh now", action: #selector(refreshNowAction), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit Codenotch", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView ?? self)
    }

    @objc private func togglePinnedAction() {
        channel?.invokeMethod("onTogglePinned", nil)
    }

    @objc private func refreshNowAction() {
        channel?.invokeMethod("onRefresh", nil)
    }

    @objc private func quitAction() {
        NSApplication.shared.terminate(nil)
    }
}
