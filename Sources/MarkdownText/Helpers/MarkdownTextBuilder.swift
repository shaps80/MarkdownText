import SwiftUI
import Markdown

struct MarkdownTextBuilder: MarkupWalker {
    enum ListType {
        case unordered
        case ordered
        case checklist
    }

    var components: [Component] = []
    var elements: [MarkdownElement] = []
    var isNested: Bool = false
    var nestedElements: [MarkdownElement] = []
    var listStack: [ListType] = []

    init(document: Document) {
        visit(document)
    }

    mutating func visitHeading(_ markdown: Heading) {
        print("Heading | \(markdown.level)")
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

        if attributes.isEmpty {
            print("|\(markdown.string)|")
        } else {
            print("|\(markdown.string)| \(attributes.description)")
        }

        components.append(.init(text: .init(markdown.string), attributes: attributes))
    }

    mutating func visitParagraph(_ markdown: Paragraph) {
        print("Paragraph")
        descendInto(markdown)

        if isNested {
            nestedElements.append(.paragraph(.init(inline: .init(components: components))))
        } else {
            elements.append(.paragraph(.init(inline: .init(components: components))))
        }

        components = []
    }

    mutating func visitImage(_ markdown: Markdown.Image) {
        print("Image")
        descendInto(markdown)
    }

    mutating func visitLink(_ markdown: Markdown.Link) {
        print("Link")
        descendInto(markdown)
    }

    mutating func visitStrong(_ markdown: Strong) {
        descendInto(markdown)
    }

    mutating func visitEmphasis(_ markdown: Emphasis) {
        descendInto(markdown)
    }

    mutating func visitInlineCode(_ markdown: InlineCode) {
        print("|\(markdown.code)| \(Attribute.code.description)")
        components.append(.init(text: .init(markdown.code), attributes: .code))
    }

    mutating func visitStrikethrough(_ markdown: Strikethrough) {
        descendInto(markdown)
    }

    mutating func visitCodeBlock(_ markdown: CodeBlock) {
        print("Code")
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
        isNested = true
        print("List item")
        descendInto(markdown)

        for element in nestedElements {
            if case let .paragraph(config) = element {
                switch listStack.last {
                case .ordered:
                    elements.append(.orderedList(.init(
                        level: listStack.count - 1,
                        bullet: .init(order: markdown.indexInParent + 1),
                        paragraph: config))
                    )
                default:
                    if let checkbox = markdown.checkbox {
                        elements.append(.checklist(.init(
                            level: listStack.count - 1,
                            bullet: .init(isChecked: checkbox == .checked),
                            paragraph: config))
                        )
                    } else {
                        elements.append(.unorderedList(.init(
                            level: listStack.count - 1,
                            bullet: .init(),
                            paragraph: config))
                        )
                    }
                }
            }
        }

        components = []
        nestedElements = []
        isNested = false
    }

    mutating func visitBlockQuote(_ markdown: BlockQuote) {
        isNested = true
        print("Quote")
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
        print("Custom block")
        descendInto(markdown)
    }

    mutating func visitCustomInline(_ markdown: CustomInline) {
        print("Custom inline")
        descendInto(markdown)
    }

    mutating func visitBlockDirective(_ markdown: BlockDirective) {
        print("Block directive")
        descendInto(markdown)
    }

    mutating func visitInlineHTML(_ markdown: InlineHTML) {
        visitText(.init(markdown.plainText))
    }
}
