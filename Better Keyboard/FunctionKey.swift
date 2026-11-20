import Carbon.HIToolbox

enum FunctionKey: Int, CaseIterable, Identifiable {
    case f1 = 1, f2, f3, f4, f5, f6, f7, f8, f9, f10
    case f11, f12, f13, f14, f15, f16, f17, f18, f19, f20

    var id: Int { rawValue }

    var title: String { "F\(rawValue)" }

    var keyCode: Int {
        switch self {
        case .f1: kVK_F1
        case .f2: kVK_F2
        case .f3: kVK_F3
        case .f4: kVK_F4
        case .f5: kVK_F5
        case .f6: kVK_F6
        case .f7: kVK_F7
        case .f8: kVK_F8
        case .f9: kVK_F9
        case .f10: kVK_F10
        case .f11: kVK_F11
        case .f12: kVK_F12
        case .f13: kVK_F13
        case .f14: kVK_F14
        case .f15: kVK_F15
        case .f16: kVK_F16
        case .f17: kVK_F17
        case .f18: kVK_F18
        case .f19: kVK_F19
        case .f20: kVK_F20
        }
    }
}
