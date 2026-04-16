@testable import AsyncButtonKit
import Testing
import SwiftUI

@Suite struct AsyncButtonTests {
    @Test func defaultOptions() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isLoadingEnvironment: false, options: [])

        #expect(state.isNewExecutingAllowed, "It should allow new execution when not executing.")
        #expect(!state.shouldCancelPreviousTask, "Previous task should not be canceled")
        #expect(!state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
    }

    @Test func defaultOptionsWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: [])

        #expect(!state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        #expect(!state.shouldCancelPreviousTask, "Previous task should not be canceled")
        #expect(!state.isButtonDisabled, "Button should not be disabled with default options set when executing")
        #expect(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
    }

    @Test func defaultOptionsWhenSameIdentifierIsExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 0, isLoadingEnvironment: false, options: [])

        #expect(!state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        #expect(!state.shouldCancelPreviousTask, "Previous task should not be canceled")
        #expect(!state.isButtonDisabled, "Button should not be disabled with default options set and same identifier executing.")
        #expect(state.isButtonLoading, "Button should be in loading state when same identifier is executing.")
    }

    @Test func defaultOptionsWhenExecutingWithIdentifier() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isExecuting: 0, isLoadingEnvironment: false, options: [])

        #expect(!state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        #expect(!state.shouldCancelPreviousTask, "Previous task should not be canceled")
        #expect(!state.isButtonDisabled, "Button should not be disabled with default options set and executing with identifier.")
        #expect(state.isButtonLoading, "Button should be in loading state when executing with same identifier.")
    }

    @Test func defaultOptionsWhenDifferentIdentifierIsExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 1, isLoadingEnvironment: false, options: [])

        #expect(!state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        #expect(!state.shouldCancelPreviousTask, "Previous task should not be canceled")
        #expect(state.isButtonDisabled, "Button should be disabled with default options set and isExecutingInternal is true.")
        #expect(!state.isButtonLoading, "Button should not be in a loading state when different identifier executes.")
    }

    @Test func allowsConcurrentExecutionsOption() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: .allowsConcurrentExecutions)

        #expect(state.isNewExecutingAllowed, "It should allow new execution when .allowsConcurrentExecutions option is set.")
        #expect(!state.shouldCancelPreviousTask, "Previous task should not be canceled")
        #expect(!state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
        #expect(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
    }

    @Test func cancelsRunningExecutionOption() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isLoadingEnvironment: false, options: .cancelsRunningExecution)

        #expect(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        #expect(state.shouldCancelPreviousTask, "Previous task should be canceled")
        #expect(!state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
        #expect(!state.isButtonDisabled, "Button should not be disabled when isExecutingInternal is false")
    }

    @Test func cancelsRunningExecutionOptionWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: .cancelsRunningExecution)

        #expect(!state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        #expect(state.shouldCancelPreviousTask, "Previous task should be canceled")
        #expect(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
        #expect(!state.isButtonDisabled, "Button should not be disabled when only .cancelsRunningExecution option is set")
    }

    @Test func cancelsRunningExecutionWithConcurrentExecutionsOptions() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isLoadingEnvironment: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        #expect(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        #expect(state.shouldCancelPreviousTask, "Previous task should be canceled")
        #expect(!state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
        #expect(!state.isButtonDisabled, "Button should not be disabled when .allowsConcurrentExecutions option is set")
    }

    @Test func cancelsRunningExecutionWithConcurrentExecutionsOptionsWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        #expect(state.isNewExecutingAllowed, "It should allow isNewExecutingAllowed when .allowsConcurrentExecutions option is set")
        #expect(state.shouldCancelPreviousTask, "Previous task should be canceled")
        #expect(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
        #expect(!state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
    }

    @Test func cancelsRunningExecutionWithConcurrentExecutionsOptionsWhenDifferentIdentifierExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 1, isLoadingEnvironment: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        #expect(state.isNewExecutingAllowed, "It should allow isNewExecutingAllowed when .allowsConcurrentExecutions option is set")
        #expect(state.shouldCancelPreviousTask, "Previous task should be canceled")
        #expect(!state.isButtonLoading, "Button should not be in a loading state when different identifier is executing.")
        #expect(!state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
    }

    @Test func isLoadingEnvironment() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: nil, isLoadingEnvironment: true, options: [])

        #expect(!state.isNewExecutingAllowed, "It should not allow new execution with default options")
        #expect(!state.shouldCancelPreviousTask, "It should not allow cancel previous task with default options")
        #expect(state.isButtonLoading, "Button should be in loading state with isLoadingEnvironment is true.")
        #expect(!state.isButtonDisabled, "Button should not be disabled when isLoadingEnvironment is true.")
    }
}
