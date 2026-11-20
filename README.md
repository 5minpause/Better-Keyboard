# Better Keyboard

A tiny macOS menu bar app that turns your function keys into app switchers.

Press a function key and the app assigned to it

- **launches** if it isn't running,
- **comes to the front** if it's running in the background or hidden,
- **hides** if it's already frontmost.

That's it. One key per app, toggled in and out of view.

## Why

I used [BetterTouchTool](https://folivora.ai) for exactly this one feature. BTT is great, but paying for a license just to map F-keys to apps felt like overkill, so this is the single-purpose replacement.

## Features

- F1–F20 can each be mapped to any app
- Lives in the menu bar, no Dock icon
- No Accessibility or Input Monitoring permission required
- Mappings are stored by bundle identifier, so they survive app updates and moves
- Optional launch at login

## Requirements

- macOS 15 or later
- F1–F12 must send real function keys. Either
  - enable **System Settings → Keyboard → Keyboard Shortcuts… → Function Keys → Use F1, F2, etc. keys as standard function keys**, or
  - hold <kbd>fn</kbd> while pressing the key.

  F13–F20 on extended keyboards work without this setting.

## Installation

### Build from source

1. Clone the repository and open `Better Keyboard.xcodeproj` in Xcode.
2. Select your team under **Signing & Capabilities**.
3. Run with <kbd>⌘R</kbd>, or create a signed, notarized build via **Product → Archive → Distribute App → Direct Distribution**.
4. Move the exported app to `/Applications` and start it from there.

## Usage

1. Click the keyboard icon in the menu bar and choose **Einstellungen…** (Settings).
2. Click a row to pick the app for that key. Use ✕ to remove a mapping.
3. Turn on **Beim Login starten** (launch at login) if you want it to start automatically.

A ⚠️ next to a key means it couldn't be registered because another app or a system shortcut already uses it. Quit the other app (e.g. BetterTouchTool) or free the shortcut, for example F11 for *Show Desktop* under **Keyboard Shortcuts → Mission Control**.

## How it works

- Global hotkeys are registered with Carbon's `RegisterEventHotKey`, which only receives the exact keys it registered for and therefore needs no special permissions.
- Apps are brought forward with `NSWorkspace.openApplication(at:configuration:)` and hidden with `NSRunningApplication.hide()`.
- The app is not sandboxed, because hiding other apps isn't reliable from inside the App Sandbox. It uses the Hardened Runtime and is meant to be distributed with Developer ID and notarization.

## License

[MIT](LICENSE)
