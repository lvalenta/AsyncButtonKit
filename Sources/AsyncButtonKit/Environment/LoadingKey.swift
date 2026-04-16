//
//  SwiftUIView.swift
//  
//
//  Created by Lukáš Valenta on 17.04.2023.
//

import SwiftUI

public struct LoadingKey: EnvironmentKey {
    public static let defaultValue: Bool = false
}

@available(macOS 10.15, *)
public extension EnvironmentValues {
    @inlinable
    var isLoading: Bool {
        get { self[LoadingKey.self] }
        set { self[LoadingKey.self] = newValue }
    }
}

@available(macOS 10.15, *)
public extension View {
    @inlinable
    func isLoading(_ isLoading: Bool) -> some View {
        environment(\.isLoading, isLoading)
    }
}
