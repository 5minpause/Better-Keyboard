import AppKit
import SwiftUI

@main
struct BetterKeyboardApp: App {
    @State private var keyMap = KeyMap()

    var body: some Scene {
        MenuBarExtra("Better Keyboard", systemImage: "keyboard") {
            MenuContent()
        }
        Window("Better Keyboard", id: SettingsView.windowID) {
            SettingsView()
                .environment(keyMap)
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)
    }
}

private struct MenuContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Einstellungen…") {
            openWindow(id: SettingsView.windowID)
            NSApp.activate()
        }
        .keyboardShortcut(",")
        Divider()
        Button("Beenden") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
