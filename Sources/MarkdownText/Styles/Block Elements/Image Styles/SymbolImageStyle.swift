import SwiftUI

/// An image style that renders an SFSymbol (if possible)
public struct SFSymbolImageMarkdownStyle: ImageMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        if let source = configuration.source {
            Image(systemName: source)
        }
    }
}

public extension ImageMarkdownStyle where Self == SFSymbolImageMarkdownStyle {
    /// An image style that renders an SFSymbol (if possible)
    ///
    /// Example:
    ///
    ///     ![](star)
    ///
    static var symbol: Self { .init() }
}
