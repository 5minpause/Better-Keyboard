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

### Download

1. Download the latest `Better-Keyboard-<version>.zip` from [Releases](https://github.com/5minpause/Better-Keyboard/releases/latest).
2. Unzip it and move **Better Keyboard.app** to `/Applications`.
3. Open it. The app is signed with a Developer ID and notarized by Apple, so it opens without Gatekeeper warnings.

### Build from source

1. Clone the repository and open `Better Keyboard.xcodeproj` in Xcode.
2. Select your team under **Signing & Capabilities**.
3. Run with <kbd>⌘R</kbd>, or create a signed, notarized build via **Product → Archive → Distribute App → Direct Distribution**.
4. Move the exported app to `/Applications` and start it from there.

## Usage

1. Click the keyboard icon in the menu bar and choose **Settings…**.
2. Click a row to pick the app for that key. Use ✕ to remove a mapping.
3. Turn on **Launch at login** if you want it to start automatically.

A ⚠️ next to a key means it couldn't be registered because another app or a system shortcut already uses it. Quit the other app (e.g. BetterTouchTool) or free the shortcut, for example F11 for *Show Desktop* under **Keyboard Shortcuts → Mission Control**.

The interface is available in English and German.

### Ideas for a layout

All keys start empty. One way to set them up is by the role an app plays in your day, so the muscle memory stays the same even when you switch tools:

| Key | Role |
|---|---|
| F1 | Browser |
| F2 | Team chat |
| F3 | Code editor |
| F4 | Mail |
| F5 | Terminal |
| F6 | Notes |
| F7 | Calendar |
| F8 | Music |
| F9 | AI assistant |
| F10 | Git client |

## How it works

- Global hotkeys are registered with Carbon's `RegisterEventHotKey`, which only receives the exact keys it registered for and therefore needs no special permissions.
- Apps are brought forward with `NSWorkspace.openApplication(at:configuration:)` and hidden with `NSRunningApplication.hide()`.
- The app is not sandboxed, because hiding other apps isn't reliable from inside the App Sandbox. It uses the Hardened Runtime and is meant to be distributed with Developer ID and notarization.

## Releasing

`scripts/release.sh` archives the app, exports it with Developer ID, notarizes and staples it, zips it and publishes a GitHub release tagged `v<MARKETING_VERSION>`.

One-time setup:

```sh
brew install gh
gh auth login
xcrun notarytool store-credentials better-keyboard --apple-id <apple-id> --team-id <team-id>
```

`notarytool` asks for an [app-specific password](https://account.apple.com). Then bump the version in Xcode and run:

```sh
scripts/release.sh                 # build, notarize and publish
scripts/release.sh --skip-publish  # build and notarize only
```

## License

[MIT](LICENSE)
