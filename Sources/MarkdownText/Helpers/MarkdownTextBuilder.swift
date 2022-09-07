import SwiftUI
import Markdown

public struct MarkdownList {
    public enum ListType {
        case unordered
        case ordered
    }

    public let type: ListType
    public var elements: [MarkdownListElement] = []

    mutating func append(ordered item: OrderedListItemMarkdownConfiguration) {
        elements.append(.ordered(item))
    }

    mutating func append(unordered item: UnorderedListItemMarkdownConfiguration) {
        elements.append(.unordered(item))
    }

    mutating func append(checklist item: CheckListItemMarkdownConfiguration) {
        elements.append(.checklist(item))
    }

    mutating func append(nested list: Self) {
        elements.append(.list(list))
    }
}

struct MarkdownTextBuilder: MarkupWalker {
    var isNested: Bool = false
    var nestedBlockElements: [MarkdownBlockElement] = []
    var inlineElements: [MarkdownInlineElement] = []
    var blockElements: [MarkdownBlockElement] = []
    var lists: [MarkdownList] = []

    init(document: Document) {
        visit(document)
    }

    mutating func visitHeading(_ markdown: Heading) {
        descendInto(markdown)
        blockElements.append(.header(.init(level: markdown.level, inline: .init(components: inlineElements))))
        inlineElements = []
    }

    mutating func visitText(_ markdown: Markdown.Text) {
        var attributes: InlineAttributes = []
        var parent = markdown.parent
        var text = markdown.string

        while parent != nil {
            defer { parent = parent?.parent }

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

            if let link = parent as? Markdown.Link {
                #warning("Links")
                /*
                 One idea here could be to collect links like footnotes, reference them in the rendered result as such (at least by default) and then add actual buttons to the bottom of the rendered output?
                 */
                attributes.insert(.link)
                text = link.plainText //+ (link.destination.flatMap { " [\($0)]" } ?? "")
            }
        }

        inlineElements.append(.init(text: .init(text), attributes: attributes))
    }

    mutating func visitOrderedList(_ markdown: OrderedList) {
        lists.append(.init(type: .ordered))
        descendInto(markdown)

        if let list = lists.last {
            if lists.count == 1 {
                // if we're at the root element, add the the tree to the block elements
                blockElements.append(.list(.init(list: list, level: lists.count - 1)))
            } else {
                // otherwise, append nested lists to the last list
                let index = lists.index(before: lists.index(before: lists.endIndex))
                lists[index].append(nested: list)
            }
        }

        lists.removeLast()
    }

    mutating func visitUnorderedList(_ markdown: UnorderedList) {
        lists.append(.init(type: .unordered))
        descendInto(markdown)

        if let list = lists.last {
            if lists.count == 1 {
                // if we're at the root element, add the the tree to the block elements
                blockElements.append(.list(.init(list: list, level: lists.count - 1)))
            } else {
                // otherwise, append nested lists to the last list
                let index = lists.index(before: lists.index(before: lists.endIndex))
                lists[index].append(nested: list)
            }
        }

        lists.removeLast()
    }

    mutating func visitListItem(_ markdown: Markdown.ListItem) {
        descendInto(markdown)
    }

    mutating func visitParagraph(_ markdown: Paragraph) {
        descendInto(markdown)

        if let listItem = markdown.parent as? ListItem {
            let index = lists.index(before: lists.endIndex)

            switch lists[index].type {
            case .ordered:
                lists[index].append(ordered: .init(
                    level: lists.count - 1,
                    bullet: .init(order: listItem.indexInParent + 1),
                    paragraph: .init(inline: .init(components: inlineElements)))
                )
            default:
                if let checkbox = listItem.checkbox {
                    lists[index].append(checklist: .init(
                        level: lists.count - 1,
                        bullet: .init(isChecked: checkbox == .checked),
                        paragraph: .init(inline: .init(components: inlineElements)))
                    )
                } else {
                    lists[index].append(unordered: .init(
                        level: lists.count - 1,
                        bullet: .init(level: lists.count - 1),
                        paragraph: .init(inline: .init(components: inlineElements)))
                    )
                }
            }
        } else {
            if isNested {
                nestedBlockElements.append(.paragraph(.init(inline: .init(components: inlineElements))))
            } else {
                blockElements.append(.paragraph(.init(inline: .init(components: inlineElements))))
            }
        }

        inlineElements = []
    }

    mutating func visitImage(_ markdown: Markdown.Image) {
        blockElements.append(.image(.init(source: markdown.source, title: markdown.title)))
    }

    mutating func visitLink(_ markdown: Markdown.Link) {
        descendInto(markdown)
    }

    mutating func visitStrong(_ markdown: Strong) {
        descendInto(markdown)
    }

    mutating func visitEmphasis(_ markdown: Emphasis) {
        descendInto(markdown)
    }

    mutating func visitInlineCode(_ markdown: InlineCode) {
        inlineElements.append(.init(text: .init(markdown.code), attributes: .code))
    }

    mutating func visitStrikethrough(_ markdown: Strikethrough) {
        descendInto(markdown)
    }

    mutating func visitCodeBlock(_ markdown: CodeBlock) {
        blockElements.append(.code(.init(code: markdown.code, language: markdown.language)))
        inlineElements = []
    }

    mutating func visitThematicBreak(_ markdown: ThematicBreak) {
        blockElements.append(.thematicBreak(.init()))
        descendInto(markdown)
    }

    mutating func visitBlockQuote(_ markdown: BlockQuote) {
        isNested = true
        descendInto(markdown)

        for element in nestedBlockElements {
            if case let .paragraph(config) = element {
                blockElements.append(.quote(.init(paragraph: config)))
            }
        }

        inlineElements = []
        nestedBlockElements = []
        isNested = false
    }

    mutating func visitTable(_ markdown: Markdown.Table) {
        #warning("TBD")
    }

    mutating func visitTableRow(_ markdown: Markdown.Table.Row) {
        #warning("TBD")
    }

    mutating func visitTableBody(_ tableBody: Markdown.Table.Body) {
        #warning("TBD")
    }

    mutating func visitTableCell(_ tableCell: Markdown.Table.Cell) {
        #warning("TBD")
    }

    mutating func visitTableHead(_ tableHead: Markdown.Table.Head) {
        #warning("TBD")
    }

    mutating func visitSymbolLink(_ markdown: SymbolLink) { }
    mutating func visitBlockDirective(_ markdown: BlockDirective) { }
    mutating func visitCustomInline(_ customInline: CustomInline) { }
    mutating func visitHTMLBlock(_ markdown: HTMLBlock) { }
    mutating func visitInlineHTML(_ markdown: InlineHTML) { }
}
