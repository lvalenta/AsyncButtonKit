//
//  ReadSize.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

@available(macOS 10.15, *)
extension View {
    @inlinable
    public func readSize(onChange: @Sendable @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { metrics in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: metrics.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    @inlinable
    public func readMaxSize(onChange: @Sendable @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { metrics in
                Color.clear
                    .preference(key: MaxSizePreferenceKey.self, value: metrics.size)
            }
        )
        .onPreferenceChange(MaxSizePreferenceKey.self, perform: onChange)
    }

    
}

public struct SizePreferenceKey: PreferenceKey {
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}

    public static let defaultValue: CGSize = .zero
}

public struct MaxSizePreferenceKey: PreferenceKey {
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = max(value, nextValue())
    }

    public static let defaultValue: CGSize = .zero
}
