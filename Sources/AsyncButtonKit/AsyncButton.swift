//
//  AsyncButton.swift
//
//
//  Created by Lukáš Valenta on 23.08.2023.
//

import SwiftUI

/// An option set that defines behaviors for `AsyncButton`.
public struct AsyncButtonOptions: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// An option that allows the button to initiate multiple executions concurrently.
    public static let allowsConcurrentExecutions = Self(rawValue: 1 << 0)

    /// An option that causes the button to abort any running execution when a new execution is initiated.
    public static let cancelsRunningExecution = Self(rawValue: 1 << 1)
}

/// A button that initiates an asynchronous action when tapped.
///
/// This button is designed to handle concurrent or repeated taps by using the behaviors defined in `AsyncButtonOptions`.
public struct AsyncButton<Label: View, Identifier: Equatable>: View {

    /// The unique identifier for the button.
    public var id: Identifier

    /// The asynchronous action to perform when the button is tapped.
    public var action: () async -> Void
    
    /// The visual label for the button.
    public var label: Label
    
    /// A binding that tracks whether the button's action is currently executing.
    @Binding public var isExecuting: Identifier?

    /// The options that define the button's behavior when it's tapped.
    public var options: AsyncButtonOptions

    /// An optional semantic role describing the button's purpose.
    public var role: ButtonRole?

    /// A private state that tracks whether the button's action is currently executing.
    @State private var isExecutingInternal = false

    /// The last running task, stored for potential cancellation.
    @State private var savedTask: Task<Void, Never>?

    @Environment(\.isLoading) private var isLoading

    /// Creates a new asynchronous button with the given parameters.
    ///
    /// - Parameters:
    ///   - role: An optional semantic role describing the button.
    ///   - executingID: The unique identifier for the button.
    ///   - isExecuting: A binding that sets and stores the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure that returns the button's visual label.
    public init(role: ButtonRole? = nil,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.role = role
        self.action = action
        self.id = executingID
        self.options = options
        self.label = label()
        self._isExecuting = isExecuting
    }

    /// A structure that represents the state of the button.
    ///
    /// This structure contains properties that determine the current state of the button and its behavior based on the options set in `AsyncButtonOptions`.
    struct ButtonState {
        
        /// The unique identifier for the button.
        var id: Identifier?
        
        /// A Boolean value indicating whether the button's action is currently executing.
        var isButtonExecuting: Bool
        
        /// The unique identifier of the currently executing action, if any.
        var executingIdentifier: Identifier?
        
        /// The options that define the button's behavior when it's tapped.
        var options: AsyncButtonOptions
        
        /// Creates a new button state with the given parameters.
        ///
        /// - Parameters:
        ///   - id: The unique identifier for the button.
        ///   - isExecutingInternal: A Boolean value indicating whether the button's action is currently executing.
        ///   - isExecuting: The unique identifier of the currently executing action, if any.
        ///   - options: The options that define the button's behavior when it's tapped.
        init(id: Identifier? = nil,
             isExecutingInternal: Bool,
             isExecuting: Identifier? = nil,
             isLoadingEnvironment: Bool,
             options: AsyncButtonOptions) {
            self.id = id
            self.isButtonExecuting = isExecutingInternal || isExecuting == id || isLoadingEnvironment
            self.executingIdentifier = isExecuting
            self.options = options
        }
        
        
        /// A Boolean value indicating whether a new execution is allowed.
        ///
        /// This value is `true` if the button is not currently executing any action and there is no current executing identifier, or if the button's options allow concurrent executions.
        var isNewExecutingAllowed: Bool {
            (!isButtonExecuting && executingIdentifier == nil) || options.contains(.allowsConcurrentExecutions)
        }
        
        /// A Boolean value indicating whether the button is loading.
        ///
        /// This value is `true` if the button's action is currently executing.
        var isButtonLoading: Bool {
            isButtonExecuting
        }
        
        /// A Boolean value indicating whether the button is disabled.
        ///
        /// This value is `false` if the button's options allow concurrent executions.
        /// Otherwise, it is `true` if the button is not currently executing any action and there is a current executing identifier.
        var isButtonDisabled: Bool {
            if options.contains(.allowsConcurrentExecutions) {
                return false
            }
            
            return !isButtonExecuting && executingIdentifier != nil
        }
        
        /// A Boolean value indicating whether the previous task should be cancelled.
        ///
        /// This value is `true` if the button's options specify that running executions should be cancelled when a new execution is initiated by setting `.cancelsRunningExecuting`.
        var shouldCancelPreviousTask: Bool {
            options.contains(.cancelsRunningExecution)
        }
    }
    
    /// The body of the asynchronous button.
    public var body: some View {
        let state = ButtonState(
            id: id,
            isExecutingInternal: isExecutingInternal,
            isExecuting: isExecuting,
            isLoadingEnvironment: isLoading,
            options: options
        )

        return Button(role: role, action: {
            guard state.isNewExecutingAllowed else { return }

            if state.shouldCancelPreviousTask {
                savedTask?.cancel()
            }

            savedTask = Task { @MainActor in
                if isExecuting != id {
                    isExecuting = id
                }

                if !isExecutingInternal {
                    isExecutingInternal = true
                }

                await action()

                if !Task.isCancelled {
                    isExecuting = nil
                    isExecutingInternal = false
                }
            }
        }, label: { label })
        .buttonStyle(.isLoading(disabledWhenLoading: false))
        .isLoading(state.isButtonLoading)
        .disabled(state.isButtonDisabled)
    }
}

/// An extension for AsyncButton with a default label of type Text.
extension AsyncButton where Label == Text {

    /// Creates an asynchronous button with the given title and action.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - role: An optional semantic role describing the button.
    ///   - executingID: The unique identifier of the button that is used for setting the `isExecuting` binding.
    ///   - isExecuting: A binding that stores and sets the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                role: ButtonRole? = nil,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, executingID: executingID, isExecuting: isExecuting, options: options, action: action) { Text(title) }
    }

    /// Creates an asynchronous button with a localized title and action.
    ///
    /// - Parameters:
    ///   - titleKey: The localized key used to create the button's title.
    ///   - role: An optional semantic role describing the button.
    ///   - executingID: The unique identifier of the button that is used for setting the `isExecuting` binding.
    ///   - isExecuting: A binding that stores and sets the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, executingID: executingID, isExecuting: isExecuting, options: options, action: action) { Text(titleKey) }
    }
}

/// An extension for AsyncButton with an empty identifier.
extension AsyncButton where Identifier == EmptyAsyncButtonIdentifier {

    /// Creates an asynchronous button with a boolean execution-state binding and a custom label.
    ///
    /// - Parameters:
    ///   - role: An optional semantic role describing the button.
    ///   - isExecuting: A binding that stores and sets the execution state.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    @inlinable
    public init(role: ButtonRole? = nil,
                isExecuting: Binding<Bool>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.init(
            role: role,
            executingID: EmptyAsyncButtonIdentifier(),
            isExecuting: Binding(
                get: { isExecuting.wrappedValue ? EmptyAsyncButtonIdentifier() : nil },
                set: { isExecuting.wrappedValue = $0 != nil }),
            options: options,
            action: action,
            label: label
        )
    }

    /// Creates an asynchronous button with the given action and label.
    ///
    /// - Parameters:
    ///   - role: An optional semantic role describing the button.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    ///   - label: A closure returning the label of the button.
    @inlinable
    public init(role: ButtonRole? = nil,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void,
                label: () -> Label) {
        self.init(
            role: role,
            executingID: EmptyAsyncButtonIdentifier(),
            isExecuting: .constant(nil),
            options: options,
            action: action,
            label: label
        )
    }
}

/// An extension for AsyncButton with an empty identifier and a default label of type Text.
extension AsyncButton where Identifier == EmptyAsyncButtonIdentifier, Label == Text {

    /// Creates an asynchronous button with the given title and action.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - role: An optional semantic role describing the button.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                role: ButtonRole? = nil,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, options: options, action: action, label: { Text(title) })
    }

    /// Creates an asynchronous button with the given title, execution-state binding, and action.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - role: An optional semantic role describing the button.
    ///   - isExecuting: A binding that stores and sets the execution state.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                role: ButtonRole? = nil,
                isExecuting: Binding<Bool>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, isExecuting: isExecuting, options: options, action: action, label: { Text(title) })
    }

    /// Creates an asynchronous button with a localized title and action.
    ///
    /// - Parameters:
    ///   - titleKey: The localized key used to create the button's title.
    ///   - role: An optional semantic role describing the button.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, options: options, action: action, label: { Text(titleKey) })
    }

    /// Creates an asynchronous button with a localized title, execution-state binding, and action.
    ///
    /// - Parameters:
    ///   - titleKey: The localized key used to create the button's title.
    ///   - role: An optional semantic role describing the button.
    ///   - isExecuting: A binding that stores and sets the execution state.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                isExecuting: Binding<Bool>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, isExecuting: isExecuting, options: options, action: action, label: { Text(titleKey) })
    }
}

/// iOS 17+ `systemImage` variants for AsyncButton with an empty identifier,
/// wrapping `SwiftUI.Label<Text, Image>`.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AsyncButton where Identifier == EmptyAsyncButtonIdentifier, Label == SwiftUI.Label<Text, Image> {

    /// Creates an asynchronous button with a title and an SF Symbol icon.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - systemImage: The name of the SF Symbol to display alongside the title.
    ///   - role: An optional semantic role describing the button.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                systemImage: String,
                role: ButtonRole? = nil,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, options: options, action: action, label: { SwiftUI.Label(title, systemImage: systemImage) })
    }

    /// Creates an asynchronous button with a localized title and an SF Symbol icon.
    ///
    /// - Parameters:
    ///   - titleKey: The localized key used to create the button's title.
    ///   - systemImage: The name of the SF Symbol to display alongside the title.
    ///   - role: An optional semantic role describing the button.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ titleKey: LocalizedStringKey,
                systemImage: String,
                role: ButtonRole? = nil,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, options: options, action: action, label: { SwiftUI.Label(titleKey, systemImage: systemImage) })
    }

    /// Creates an asynchronous button with a title, SF Symbol icon, and execution-state binding.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - systemImage: The name of the SF Symbol to display alongside the title.
    ///   - role: An optional semantic role describing the button.
    ///   - isExecuting: A binding that stores and sets the execution state.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                systemImage: String,
                role: ButtonRole? = nil,
                isExecuting: Binding<Bool>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, isExecuting: isExecuting, options: options, action: action, label: { SwiftUI.Label(title, systemImage: systemImage) })
    }

    /// Creates an asynchronous button with a localized title, SF Symbol icon, and execution-state binding.
    ///
    /// - Parameters:
    ///   - titleKey: The localized key used to create the button's title.
    ///   - systemImage: The name of the SF Symbol to display alongside the title.
    ///   - role: An optional semantic role describing the button.
    ///   - isExecuting: A binding that stores and sets the execution state.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ titleKey: LocalizedStringKey,
                systemImage: String,
                role: ButtonRole? = nil,
                isExecuting: Binding<Bool>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, isExecuting: isExecuting, options: options, action: action, label: { SwiftUI.Label(titleKey, systemImage: systemImage) })
    }
}

/// iOS 17+ `systemImage` variants for AsyncButton with a custom identifier,
/// wrapping `SwiftUI.Label<Text, Image>`.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AsyncButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates an asynchronous button with a title, SF Symbol icon, and an identifier-based execution binding.
    ///
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - systemImage: The name of the SF Symbol to display alongside the title.
    ///   - role: An optional semantic role describing the button.
    ///   - executingID: The unique identifier of the button that is used for setting the `isExecuting` binding.
    ///   - isExecuting: A binding that stores and sets the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ title: some StringProtocol,
                systemImage: String,
                role: ButtonRole? = nil,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, executingID: executingID, isExecuting: isExecuting, options: options, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }

    /// Creates an asynchronous button with a localized title, SF Symbol icon, and an identifier-based execution binding.
    ///
    /// - Parameters:
    ///   - titleKey: The localized key used to create the button's title.
    ///   - systemImage: The name of the SF Symbol to display alongside the title.
    ///   - role: An optional semantic role describing the button.
    ///   - executingID: The unique identifier of the button that is used for setting the `isExecuting` binding.
    ///   - isExecuting: A binding that stores and sets the currently executing identifier.
    ///   - options: The options that define the button's behavior when it's tapped.
    ///   - action: The asynchronous action to perform when the button is tapped.
    @inlinable
    public init(_ titleKey: LocalizedStringKey,
                systemImage: String,
                role: ButtonRole? = nil,
                executingID: Identifier,
                isExecuting: Binding<Identifier?>,
                options: AsyncButtonOptions = [],
                action: @escaping () async -> Void) {
        self.init(role: role, executingID: executingID, isExecuting: isExecuting, options: options, action: action) {
            SwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }
}

/// A struct representing an empty identifier.
public struct EmptyAsyncButtonIdentifier: Equatable {
    @usableFromInline
    init() { }
}

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private func asyncButtonPreviewAction(timeInSeconds: UInt64) async {
    print("Doing activity")
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC * timeInSeconds)

    if Task.isCancelled {
        print("Task is canceled")
    } else {
        print("Finished")
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    VStack(spacing: 16) {
        AsyncButton("Test async button style", options: [.allowsConcurrentExecutions, .cancelsRunningExecution]) {
            await asyncButtonPreviewAction(timeInSeconds: 5)
        }
        .buttonStyle(.isLoading)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Synchronized AsyncButtons") {
    @Previewable @State var isExecuting: Bool = false

    VStack {
        AsyncButton("AsyncButton", isExecuting: $isExecuting) {
            await asyncButtonPreviewAction(timeInSeconds: 5)
        }
        .buttonStyle(.isLoading)

        AsyncButton("AsyncButton2", isExecuting: $isExecuting) {
            await asyncButtonPreviewAction(timeInSeconds: 5)
        }
        .buttonStyle(.isLoading)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Synchronized AsyncButtons with IDs") {
    @Previewable @State var executingID: Int? = nil

    VStack {
        AsyncButton("AsyncButton with ID 1", executingID: 1, isExecuting: $executingID) {
            await asyncButtonPreviewAction(timeInSeconds: 5)
        }
        .buttonStyle(.isLoading)

        AsyncButton("Second AsyncButton with ID 1", executingID: 1, isExecuting: $executingID) {
            await asyncButtonPreviewAction(timeInSeconds: 1)
        }
        .buttonStyle(.isLoading)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Different ID AsyncButton") {
    @Previewable @State var executingID: Int? = nil

    VStack(spacing: 16) {
        AsyncButton("AsyncButton with ID 1", executingID: 1, isExecuting: $executingID) {
            await asyncButtonPreviewAction(timeInSeconds: 5)
        }
        .buttonStyle(.isLoading)

        AsyncButton("AsyncButton with ID 3", executingID: 3, isExecuting: $executingID) {
            await asyncButtonPreviewAction(timeInSeconds: 1)
        }
        .buttonStyle(.isLoading)
    }
}
#endif
