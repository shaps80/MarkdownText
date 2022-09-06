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
    var content: Text
}

public struct OrderedItem {
    public var order: Int?
    public var content: Text
}

public struct UnorderedItem {
    var content: Text
}

public struct Component {
    public var text: Text
    public var attributes: Attribute = []
}

public struct Attribute: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let bold = Attribute(rawValue: 1 << 0)
    public static let italic = Attribute(rawValue: 1 << 1)
    public static let strikethrough = Attribute(rawValue: 1 << 2)
    public static let code = Attribute(rawValue: 1 << 3)
    public static let link = Attribute(rawValue: 1 << 4)
}

public extension Text {
    func apply(attributes: Attribute) -> Self {
        var text = self

        if attributes.contains(.bold) {
            text = text.bold()
        }

        if attributes.contains(.italic) {
            text = text.italic()
        }

        if attributes.contains(.strikethrough) {
            text = text.strikethrough()
        }

        return text
    }
}
