import SwiftUI

@available(iOS 14, *)
public struct InlineImageMarkdownStyle: ImageMarkdownStyle {
    public enum Source {
        case symbol
        case asset
    }

    public let source: Source
    public init(source: Source) {
        self.source = source
    }

    public func makeBody(configuration: Configuration) -> Text {
        switch source {
        case .symbol:
            return Text(Image(systemName: configuration.source ?? ""))
        case .asset:
            return Text(Image(configuration.source ?? ""))
        }
    }
}

@available(iOS 14, *)
public extension ImageMarkdownStyle where Self == InlineImageMarkdownStyle {
    static var inline: Self { .init(source: .symbol) }
    static func inline(source: InlineImageMarkdownStyle.Source) -> Self { .init(source: source) }
}
