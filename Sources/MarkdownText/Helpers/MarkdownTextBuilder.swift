import SwiftUI
import Markdown

struct MarkdownTextBuilder: MarkupWalker {
    enum ListItemType {
        case unordered
        case ordered
    }

    var components: [Component] = []
    var elements: [MarkdownElement] = []
    var isNested: Bool = false
    var nestedElements: [MarkdownElement] = []
    var listStack: [ListItemType] = []

    init(document: Document) {
        visit(document)
    }

    mutating func visitHeading(_ markdown: Heading) {
        descendInto(markdown)
        elements.append(.header(.init(level: markdown.level, inline: .init(components: components))))
        components = []
    }

    mutating func visitText(_ markdown: Markdown.Text) {
        var attributes: Attribute = []
        var parent = markdown.parent

        while parent != nil {
            if parent is Strong {
                attributes.insert(.bold)
            }

            if parent is Emphasis {
                attributes.insert(.italic)
            }

            if parent is Strikethrough {
                attributes.insert(.strikethrough)
            }

            if parent is InlineCode {
                attributes.insert(.code)
            }

            parent = parent?.parent
        }

        components.append(.init(text: .init(markdown.string), attributes: attributes))
    }

    mutating func visitParagraph(_ markdown: Paragraph) {
        descendInto(markdown)

        if let listItem = markdown.parent as? ListItem {
            switch listStack.last {
            case .ordered:
                elements.append(.orderedListItem(.init(
                    level: listStack.count - 1,
                    bullet: .init(order: listItem.indexInParent + 1),
                    paragraph: .init(inline: .init(components: components))))
                )
            default:
                if let checkbox = listItem.checkbox {
                    elements.append(.checklistItem(.init(
                        level: listStack.count - 1,
                        bullet: .init(isChecked: checkbox == .checked),
                        paragraph: .init(inline: .init(components: components))))
                    )
                } else {
                    elements.append(.unorderedListItem(.init(
                        level: listStack.count - 1,
                        bullet: .init(),
                        paragraph: .init(inline: .init(components: components))))
                    )
                }
            }
        } else {
            if isNested {
                nestedElements.append(.paragraph(.init(inline: .init(components: components))))
            } else {
                elements.append(.paragraph(.init(inline: .init(components: components))))
            }
        }

        components = []
    }

    mutating func visitImage(_ markdown: Markdown.Image) {
//        print("Image")
        descendInto(markdown)
    }

    mutating func visitLink(_ markdown: Markdown.Link) {
//        print("Link")
        descendInto(markdown)
    }

    mutating func visitStrong(_ markdown: Strong) {
        descendInto(markdown)
    }

    mutating func visitEmphasis(_ markdown: Emphasis) {
        descendInto(markdown)
    }

    mutating func visitInlineCode(_ markdown: InlineCode) {
        components.append(.init(text: .init(markdown.code), attributes: .code))
    }

    mutating func visitStrikethrough(_ markdown: Strikethrough) {
        descendInto(markdown)
    }

    mutating func visitCodeBlock(_ markdown: CodeBlock) {
        elements.append(.code(.init(code: markdown.code, language: markdown.language)))
        components = []
    }

    mutating func visitSoftBreak(_ markdown: SoftBreak) {
        visitText(.init(markdown.plainText))
    }

    mutating func visitThematicBreak(_ markdown: ThematicBreak) {
        elements.append(.thematicBreak(.init()))
        descendInto(markdown)
    }

    mutating func visitOrderedList(_ markdown: OrderedList) {
        print("Ordered list")
        listStack.append(.ordered)
        descendInto(markdown)
        listStack.removeLast()
    }

    mutating func visitUnorderedList(_ markdown: UnorderedList) {
        print("Unordered list")
        listStack.append(.unordered)
        descendInto(markdown)
        listStack.removeLast()
    }

    mutating func visitListItem(_ markdown: Markdown.ListItem) {
        print("List item")
        descendInto(markdown)
    }

    mutating func visitBlockQuote(_ markdown: BlockQuote) {
        isNested = true
        descendInto(markdown)

        for element in nestedElements {
            if case let .paragraph(config) = element {
                elements.append(.quote(.init(paragraph: config)))
            }
        }

        components = []
        nestedElements = []
        isNested = false
    }

    mutating func visitCustomBlock(_ markdown: CustomBlock) {
//        print("Custom block")
        descendInto(markdown)
    }

    mutating func visitCustomInline(_ markdown: CustomInline) {
//        print("Custom inline")
        descendInto(markdown)
    }

    mutating func visitBlockDirective(_ markdown: BlockDirective) {
//        print("Block directive")
        descendInto(markdown)
    }

    mutating func visitInlineHTML(_ markdown: InlineHTML) {
        visitText(.init(markdown.plainText))
    }
}
