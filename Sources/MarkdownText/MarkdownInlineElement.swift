import SwiftUI

/// Represents a single inline element, including any applied attributes (e.g. strong, italic, etc)
public struct MarkdownInlineElement {
    /// The string content for this inline element
    public var content: String
    /// The attributes to apply to this content
    public var attributes: InlineAttributes = []
}

/// Represents the supported attributes for an inline element
public struct InlineAttributes: OptionSet, CustomStringConvertible {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// A `bold` representation should be applied
    public static let bold = InlineAttributes(rawValue: 1 << 0)
    /// An `italic` representation should be applied
    public static let italic = InlineAttributes(rawValue: 1 << 1)
    /// A `strikethrough` representation should be applied
    public static let strikethrough = InlineAttributes(rawValue: 1 << 2)
    /// A `monospaced` representation should be applied
    public static let code = InlineAttributes(rawValue: 1 << 3)
    /// A link representation should be applied
    public static let link = InlineAttributes(rawValue: 1 << 4)

    public var description: String {
        var elements: [String] = []
        if contains(.bold) { elements.append("bold") }
        if contains(.italic) { elements.append("italic") }
        if contains(.strikethrough) { elements.append("strikethrough") }
        if contains(.code) { elements.append("code") }
        return elements.joined(separator: ", ")
    }
}

internal extension Text {
    func apply(
        strong: StrongMarkdownStyle,
        emphasis: EmphasisMarkdownStyle,
        strikethrough: StrikethroughMarkdownStyle,
        link: InlineLinkMarkdownStyle,
        attributes: InlineAttributes
    ) -> Self {
        var text = self

        if attributes.contains(.bold) {
            text = strong.makeBody(configuration: .init(content: text))
        }

        if attributes.contains(.italic) {
            text = emphasis.makeBody(configuration: .init(content: text))
        }

        if attributes.contains(.strikethrough) {
            text = strikethrough.makeBody(configuration: .init(content: text))
        }

        if attributes.contains(.link) {
            text = link.makeBody(configuration: .init(content: text))
        }

        return text
    }
}

