import SwiftUI
import Markdown

struct TextBuilder: MarkupWalker {
    var attributes: Attribute = []
    var components: [Component] = []
    var elements: [MarkdownElement] = []

    init(document: Document) {
        visit(document)
    }

    mutating func visitHeading(_ markdown: Heading) {
        elements.append(.header(.init(label: Text(markdown.plainText), level: markdown.level)))
        components.removeAll()
    }

    mutating func visitText(_ markdown: Markdown.Text) {
        let text = SwiftUI.Text(markdown.string)
        components.append(.init(text: text, attributes: attributes))
        attributes = []
        descendInto(markdown)
    }

    mutating func visitParagraph(_ markdown: Paragraph) {
        descendInto(markdown)

        guard !(markdown.parent is Markdown.ListItem), !(markdown.childCount == 1 && markdown.child(at: 0) is Markdown.Image) else { return }

        elements.append(.inline(.init(components: components)))
        components.removeAll()
    }

    mutating func visitOrderedList(_ markdown: OrderedList) {
        let texts = markdown.children
            .compactMap { $0 as? Markdown.ListItem }
            .flatMap(\.children)
            .compactMap { $0 as? Paragraph }
            .flatMap(\.children)
            .compactMap { $0 as? Markdown.Text }
            .map(\.plainText)

        let items = zip(texts.indices, texts).map {
            OrderedItem(order: $0.0 + 1, content: .init($0.1))
        }

        elements.append(.orderedList(.init(items: items)))
    }

    mutating func visitUnorderedList(_ markdown: UnorderedList) {
        let listItems = markdown.children
            .compactMap { $0 as? Markdown.ListItem }

        let texts = listItems
            .flatMap(\.children)
            .compactMap { $0 as? Paragraph }
            .flatMap(\.children)
            .compactMap { $0 as? Markdown.Text }
            .map(\.plainText)

        if listItems.contains(where: { $0.checkbox != nil }) {
            let checkboxes = listItems.compactMap(\.checkbox)
            let items = zip(checkboxes, texts).map {
                ChecklistItem(isChecked: $0.0 == .checked, content: .init($0.1))
            }

            elements.append(.checkedList(.init(items: items)))
        } else {
            let items = texts.map {
                UnorderedItem(content: .init($0))
            }

            elements.append(.unorderedList(.init(items: items)))
        }
    }

    mutating func visitListItem(_: Markdown.ListItem) { }

    mutating func visitImage(_ markdown: Markdown.Image) {
        descendInto(markdown)
        var title = markdown.plainText
        if markdown.title?.isEmpty == false {
            title = markdown.title ?? markdown.plainText
        }
        elements.append(.image(.init(source: markdown.source, title: title)))
    }

    mutating func visitLink(_ markdown: Markdown.Link) {
        if let destination = markdown.destination {
            let text = "\(markdown.plainText) (\(destination))"
            components.append(.init(text: .init(text), attributes: .link))
        } else {
            components.append(.init(text: .init(markdown.plainText), attributes: .link))
        }
    }

    mutating func visitStrong(_ markdown: Strong) {
        attributes.insert(.bold)
        descendInto(markdown)
    }

    mutating func visitEmphasis(_ markdown: Emphasis) {
        attributes.insert(.italic)
        descendInto(markdown)
    }

    mutating func visitInlineCode(_ markdown: InlineCode) {
        attributes.insert(.code)
        visitText(.init(markdown.code))
        descendInto(markdown)
    }

    mutating func visitStrikethrough(_ markdown: Strikethrough) {
        attributes.insert(.strikethrough)
        descendInto(markdown)
    }

    mutating func visitCodeBlock(_ markdown: CodeBlock) {
        let code = markdown.code.trimmingCharacters(in: .newlines)
        elements.append(.code(.init(code: code, language: markdown.language)))
        descendInto(markdown)
    }

    mutating func visitSoftBreak(_ markdown: SoftBreak) {
        components.append(.init(text: .init("\n")))
        descendInto(markdown)
    }

    mutating func visitThematicBreak(_ markdown: ThematicBreak) {
        elements.append(.thematicBreak(.init()))
        descendInto(markdown)
    }

    mutating func visitBlockQuote(_ markdown: BlockQuote) {
        let p = markdown.child(at: 0)
        for index in 0 ..< (p?.childCount ?? 0) {
            guard let c = p?.child(at: index) as? Markdown.Text else { continue }
            components.append(.init(text: .init(c.string)))

            if index < (p?.childCount ?? 0) - 1 {
                components.append(.init(text: .init("\n")))
            }
        }

        elements.append(.inline(.init(components: components)))
        components.removeAll()
    }
}
