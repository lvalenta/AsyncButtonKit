//
//  AsyncButtonTests.swift
//  
//
//  Created by Lukáš Valenta on 28.11.2023.
//

@testable import AsyncButtonKit
import XCTest
import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
final class AsyncButtonTests: XCTestCase {
    func testDefaultOptions() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isLoadingEnvironment: false, options: [])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow new execution when not executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
    }

    func testDefaultOptionsWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled with default options set when executing")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
    }

    func testDefaultOptionsWhenSameIdentifierIsExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 0, isLoadingEnvironment: false, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled with default options set and same identifier executing.")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when same identifier is executing.")
    }

    func testDefaultOptionsWhenExecutingWithIdentifier() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isExecuting: 0, isLoadingEnvironment: false, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled with default options set and executing with identifier.")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when executing with same identifier.")
    }

    func testDefaultOptionsWhenDifferentIdentifierIsExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 1, isLoadingEnvironment: false, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when executing.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertTrue(state.isButtonDisabled, "Button should be disabled with default options set and isExecutingInternal is true.")
        XCTAssertFalse(state.isButtonLoading, "Button should not be in a loading state when different identifier executes.")
    }

    func testAllowsConcurrentExecutionsOption() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: .allowsConcurrentExecutions)

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow new execution when .allowsConcurrentExecutions option is set.")
        XCTAssertFalse(state.shouldCancelPreviousTask, "Previous task should not be canceled")
        XCTAssertFalse(state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
    }

    func testCancelsRunningExecutionOption() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isLoadingEnvironment: false, options: .cancelsRunningExecution)

        XCTAssertTrue(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled when isExecutingInternal is false ")
    }

    func testCancelsRunningExecutionOptionWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: .cancelsRunningExecution)

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled when only .cancelsRunningExecution option is set")
    }

    func testCancelsRunningExecutionWithConcurrentExecutionsOptions() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isLoadingEnvironment: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should not allow new execution when only .cancelsRunningExecution option is set.")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should not be loading when isExecutingInternal is false")
        XCTAssertFalse(state.isButtonDisabled, "Button should not be disabled when .allowsConcurrentExecutions option is set")
    }

    func testCancelsRunningExecutionWithConcurrentExecutionsOptionsWhenExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: true, isLoadingEnvironment: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow isNewExecutingAllowed when .allowsConcurrentExecutions option is set")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state when isExecutingInternal is true.")
        XCTAssertFalse(state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
    }

    func testCancelsRunningExecutionWithConcurrentExecutionsOptionsWhenDifferentIdentifierExecuting() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: 1, isLoadingEnvironment: false, options: [.cancelsRunningExecution, .allowsConcurrentExecutions])

        XCTAssertTrue(state.isNewExecutingAllowed, "It should allow isNewExecutingAllowed when .allowsConcurrentExecutions option is set")
        XCTAssertTrue(state.shouldCancelPreviousTask, "Previous task should be canceled")
        XCTAssertFalse(state.isButtonLoading, "Button should be in loading state when different identifier is executing .")
        XCTAssertFalse(state.isButtonDisabled, "Button should be not disabled when .allowsConcurrentExecutions option is set")
    }

    func testIsLoadingEnvironment() {
        let state = AsyncButton<EmptyView, Int>.ButtonState(id: 0, isExecutingInternal: false, isExecuting: nil, isLoadingEnvironment: true, options: [])

        XCTAssertFalse(state.isNewExecutingAllowed, "It should not allow new execution with default options")
        XCTAssertFalse(state.shouldCancelPreviousTask, "It should not allow cancel previous task with default options")
        XCTAssertTrue(state.isButtonLoading, "Button should be in loading state with isLoadingEnvironment is true.")
        XCTAssertFalse(state.isButtonDisabled, "Button should be in loading state when isLoadingEnvironment is true.")
    }
}
