<p align="center">
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<img src="https://img.shields.io/badge/iOS-15.0+-blue.svg">
<img src="https://img.shields.io/badge/macOS-12.0+-blue.svg">
<img src="https://img.shields.io/badge/tvOS-15.0+-blue.svg">
<img src="https://img.shields.io/badge/watchOS-8.0+-blue.svg">
<img src="https://img.shields.io/badge/Swift-6.0-orange.svg">
<a href="blob/main/LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
</p>

# AsyncButtonKit

A tiny SwiftUI package that brings `async`/`await` to `Button`. `AsyncButton` runs an asynchronous action when tapped, tracks its execution state, shows a progress indicator while running, and gives you fine-grained control over concurrent taps.

## Features

- **Async actions** — pass an `async` closure directly; no manual `Task` wrapping.
- **Loading indicator** — while the action is in flight, the button shows a `ProgressView` overlay via the bundled `IsLoadingPrimitiveButtonStyle`.
- **Concurrency control** via `AsyncButtonOptions`:
  - `.allowsConcurrentExecutions` — allow tapping again while an action is still running.
  - `.cancelsRunningExecution` — cancel the in-flight task when a new tap is initiated.
- **Shared execution state** — bind multiple buttons to the same `Binding<Bool>` or `Binding<Identifier?>` so only one runs at a time.
- **Full `Button` API parity** — supports `role: ButtonRole?`, `LocalizedStringKey` titles, and (iOS 17+/macOS 14+) `systemImage:` variants.
- **`isLoading` environment** — propagate an external loading state into the button without writing custom styles.

## Installation

Add AsyncButtonKit to your `Package.swift`:

```swift
.package(url: "https://github.com/lvalenta/AsyncButtonKit.git", from: "1.0.0")
```

Then depend on the `AsyncButtonKit` product from your target.

**Platforms:** iOS 15, macOS 12, tvOS 15, watchOS 8. `systemImage` initializers require iOS 17 / macOS 14.

## Usage

### Basic

```swift
import AsyncButtonKit

AsyncButton("Save") {
    try? await save()
}
```

### Cancelling the running task on a new tap

```swift
AsyncButton("Refresh", options: .cancelsRunningExecution) {
    await reload()
}
```

### Shared execution state across buttons

Bind several buttons to the same `Bool`; only one runs at a time and all show loading:

```swift
@State private var isExecuting = false

AsyncButton("Primary", isExecuting: $isExecuting) { await primary() }
AsyncButton("Secondary", isExecuting: $isExecuting) { await secondary() }
```

Or use an identifier so the currently-running button knows which one it is:

```swift
@State private var runningID: Int? = nil

AsyncButton("One", executingID: 1, isExecuting: $runningID) { await work(1) }
AsyncButton("Two", executingID: 2, isExecuting: $runningID) { await work(2) }
```

### Role and system image

```swift
AsyncButton("Delete", systemImage: "trash", role: .destructive) {
    await delete()
}
```

### Driving loading from the environment

```swift
MyAsyncButton()
    .isLoading(viewModel.isLoading)
```

## License

[MIT](LICENSE.md)
