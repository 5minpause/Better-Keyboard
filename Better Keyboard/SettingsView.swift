import AppKit
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    static let windowID = "settings"

    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Section("Tasten") {
                ForEach(FunctionKey.allCases) { key in
                    KeyRow(key: key)
                }
            }
            Section {
                Toggle("Beim Login starten", isOn: Binding(get: { launchAtLogin }, set: setLaunchAtLogin))
            }
        }
        .formStyle(.grouped)
        .frame(width: 480, height: 640)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Launch at login failed: \(error)")
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}

private struct KeyRow: View {
    let key: FunctionKey
    @Environment(KeyMap.self) private var keyMap

    private static let iconSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 12) {
            Text(key.title)
                .monospacedDigit()
                .fontWeight(.medium)
                .frame(width: 32, alignment: .leading)

            Button(action: chooseApp) {
                HStack(spacing: 8) {
                    appIcon
                    appName
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("App wählen")

            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
                .help("Taste ist bereits von einer anderen App belegt")
                .opacity(keyMap.failedKeys.contains(key) ? 1 : 0)

            Button {
                keyMap.assign(nil, to: key)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .help("Zuordnung entfernen")
            .opacity(keyMap.apps[key] == nil ? 0 : 1)
            .disabled(keyMap.apps[key] == nil)
        }
    }

    @ViewBuilder
    private var appIcon: some View {
        if let url = keyMap.appURL(for: key) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                .resizable()
                .frame(width: Self.iconSize, height: Self.iconSize)
        } else {
            Image(systemName: keyMap.apps[key] == nil ? "plus.circle" : "questionmark.app.dashed")
                .font(.system(size: 15))
                .foregroundStyle(.tertiary)
                .frame(width: Self.iconSize, height: Self.iconSize)
        }
    }

    @ViewBuilder
    private var appName: some View {
        if let url = keyMap.appURL(for: key) {
            Text(url.deletingPathExtension().lastPathComponent)
        } else if let bundleID = keyMap.apps[key] {
            Text("\(bundleID) (nicht installiert)")
                .foregroundStyle(.secondary)
        } else {
            Text("App wählen…")
                .foregroundStyle(.tertiary)
        }
    }

    private func chooseApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        guard panel.runModal() == .OK,
              let url = panel.url,
              let bundleID = Bundle(url: url)?.bundleIdentifier
        else { return }
        keyMap.assign(bundleID, to: key)
    }
}
