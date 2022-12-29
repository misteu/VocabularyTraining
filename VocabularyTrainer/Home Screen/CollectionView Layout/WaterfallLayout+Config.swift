//
//  WaterfallTrueCompositionalLayout+Config.swift
//
//
//  Created by Evgeny Shishko on 12.09.2022.
//
import UIKit

public extension WaterfallTrueCompositionalLayout {
    typealias ItemHeightProvider = (_ index: Int, _ itemWidth: CGFloat) -> CGFloat
    typealias ItemCountProvider = () -> Int

    struct Configuration {
        public let columnCount: Int
        public let interItemSpacing: CGFloat
        public let contentInsetsReference: UIContentInsetsReference
        public let itemHeightProvider: ItemHeightProvider
        public let itemCountProvider: ItemCountProvider

        /// Initialization for configuration of waterfall compositional layout section
        /// - Parameters:
        ///   - columnCount: a number of columns
        ///   - interItemSpacing: a spacing between columns and rows
        ///   - contentInsetsReference: a reference point for content insets for a section
        ///   - itemCountProvider: closure providing a number of items in a section
        ///   - itemHeightProvider: closure for providing an item height at a specific index
        public init(
            columnCount: Int = 2,
            interItemSpacing: CGFloat = 8,
            contentInsetsReference: UIContentInsetsReference = .automatic,
            itemCountProvider: @escaping ItemCountProvider,
            itemHeightProvider: @escaping ItemHeightProvider
        ) {
            self.columnCount = columnCount
            self.interItemSpacing = interItemSpacing
            self.contentInsetsReference = contentInsetsReference
            self.itemCountProvider = itemCountProvider
            self.itemHeightProvider = itemHeightProvider
        }
    }
}
