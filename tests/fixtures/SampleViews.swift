import SwiftUI
import AppKit

struct SampleDashboardView: View {
    @State private var isActive: Bool = false
    @ObservedObject var store: SampleStore

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("Dashboard")
                    .font(.headline)
                Spacer()
                Button(action: { isActive.toggle() }) {
                    Text("Toggle")
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                Text("Content Area")
            }
        }
        .padding(16)
    }
}

struct SampleBadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

class SamplePanelController: NSWindowController {
    var panel: NSPanel?
    var statusItem: NSStatusItem?
}
