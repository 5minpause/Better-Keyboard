import AppKit
import Observation

@Observable
final class KeyMap {
    private static let defaultsKey = "keyMap"

    private static let initial: [FunctionKey: String] = [
        .f1: "com.vivaldi.Vivaldi",
        .f2: "Mattermost.Desktop",
        .f3: "com.microsoft.VSCode",
        .f4: "com.microsoft.Outlook",
        .f5: "com.mitchellh.ghostty",
        .f6: "md.obsidian",
        .f7: "com.apple.iCal",
        .f9: "com.anthropic.claudefordesktop",
        .f10: "com.DanPristupov.Fork",
    ]

    private(set) var apps: [FunctionKey: String]
    private(set) var failedKeys: Set<FunctionKey> = []

    init() {
        if let stored = UserDefaults.standard.dictionary(forKey: Self.defaultsKey) as? [String: String] {
            apps = Dictionary(uniqueKeysWithValues: stored.compactMap { rawKey, bundleID in
                Int(rawKey).flatMap(FunctionKey.init(rawValue:)).map { ($0, bundleID) }
            })
        } else {
            apps = Self.initial
        }
        registerHotKeys()
    }

    func assign(_ bundleID: String?, to key: FunctionKey) {
        apps[key] = bundleID
        let stored = Dictionary(uniqueKeysWithValues: apps.map { (String($0.key.rawValue), $0.value) })
        UserDefaults.standard.set(stored, forKey: Self.defaultsKey)
        registerHotKeys()
    }

    func appURL(for key: FunctionKey) -> URL? {
        apps[key].flatMap { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) }
    }

    private func registerHotKeys() {
        HotKeyCenter.shared.unregisterAll()
        failedKeys = []
        for (key, bundleID) in apps {
            let registered = HotKeyCenter.shared.register(keyCode: key.keyCode, id: UInt32(key.rawValue)) {
                AppToggler.toggle(bundleID: bundleID)
            }
            if !registered {
                failedKeys.insert(key)
            }
        }
    }
}
