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
    public func readMaxHeight(onChange: @Sendable @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { metrics in
                Color.clear
                    .preference(key: MaxHeightPreferenceKey.self, value: metrics.size.height)
            }
        )
        .onPreferenceChange(MaxHeightPreferenceKey.self, perform: onChange)
    }

    
}

public struct SizePreferenceKey: PreferenceKey {
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}

    public static let defaultValue: CGSize = .zero
}

public struct MaxHeightPreferenceKey: PreferenceKey {
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }

    public static let defaultValue: CGFloat = .zero
}
