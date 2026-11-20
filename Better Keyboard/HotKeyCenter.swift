import Carbon.HIToolbox

final class HotKeyCenter {
    static let shared = HotKeyCenter()

    private static let signature: OSType = "BKBD".utf8.reduce(0) { $0 << 8 | OSType($1) }

    private var hotKeys: [UInt32: (ref: EventHotKeyRef, action: () -> Void)] = [:]

    private init() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), hotKeyEventHandler, 1, &eventType, nil, nil)
    }

    func register(keyCode: Int, id: UInt32, action: @escaping () -> Void) -> Bool {
        var ref: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: Self.signature, id: id)
        let status = RegisterEventHotKey(UInt32(keyCode), 0, hotKeyID, GetApplicationEventTarget(), 0, &ref)
        guard status == noErr, let ref else { return false }
        hotKeys[id] = (ref, action)
        return true
    }

    func unregisterAll() {
        hotKeys.values.forEach { UnregisterEventHotKey($0.ref) }
        hotKeys.removeAll()
    }

    fileprivate func handle(_ id: UInt32) {
        hotKeys[id]?.action()
    }
}

nonisolated private func hotKeyEventHandler(_: EventHandlerCallRef?, _ event: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus {
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )
    guard status == noErr else { return status }
    MainActor.assumeIsolated {
        HotKeyCenter.shared.handle(hotKeyID.id)
    }
    return noErr
}
