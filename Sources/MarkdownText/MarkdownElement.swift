import SwiftUI

enum MarkdownElement {
    case header(HeaderMarkdownConfiguration)
    case paragraph(ParagraphMarkdownConfiguration)
    case quote(QuoteMarkdownConfiguration)

    case orderedList(OrderedListMarkdownConfiguration)
    case unorderedList(UnorderedListMarkdownConfiguration)
    case checkedList(CheckedListMarkdownConfiguration)

    case code(CodeMarkdownConfiguration)
    case thematicBreak(ThematicMarkdownConfiguration)

    case inline(InlineMarkdownConfiguration)
    case image(ImageMarkdownConfiguration)
}

public struct ChecklistItem {
    var isChecked: Bool
    var label: Text
}

public struct OrderedItem {
    public var order: Int?
    public var label: Text
}

public struct UnorderedItem {
    var label: Text
}

internal struct Component {
    var text: Text
    var attributes: Attribute = []
}

internal struct Attribute: OptionSet, CustomStringConvertible {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let bold = Attribute(rawValue: 1 << 0)
    static let italic = Attribute(rawValue: 1 << 1)
    static let strikethrough = Attribute(rawValue: 1 << 2)
    static let code = Attribute(rawValue: 1 << 3)
    static let link = Attribute(rawValue: 1 << 4)

    var description: String {
        var elements: [String] = []
        if contains(.bold) { elements.append("bold") }
        if contains(.italic) { elements.append("italic") }
        if contains(.strikethrough) { elements.append("strikethrough") }
        if contains(.code) { elements.append("code") }
        if contains(.link) { elements.append("link") }
        return elements.joined(separator: ", ")
    }
}

internal extension Text {
    func apply(strong: StrongMarkdownStyle, emphasis: EmphasisMarkdownStyle, strikethrough: StrikethroughMarkdownStyle, attributes: Attribute) -> Self {
        var text = self

        if attributes.contains(.bold) {
            text = strong.makeBody(configuration: .init(label: text))
        }

        if attributes.contains(.italic) {
            text = emphasis.makeBody(configuration: .init(label: text))
        }

        if attributes.contains(.strikethrough) {
            text = strikethrough.makeBody(configuration: .init(label: text))
        }

        return text
    }
}
