import SwiftUI
import Markdown

private struct MarkdownContent: View {
    @Environment(\.multilineTextAlignment) private var alignment

    @Environment(\.markdownHeadingStyle) private var headerStyle
    @Environment(\.markdownParagraphStyle) private var paragraphStyle
    @Environment(\.markdownQuoteStyle) private var quoteStyle
    @Environment(\.markdownCodeStyle) private var codeStyle
    @Environment(\.markdownThematicBreakStyle) private var thematicBreak
    @Environment(\.markdownListStyle) private var listStyle
    @Environment(\.markdownImageStyle) private var imageStyle

    @Environment(\.markdownCodeVisibility) private var codeVisibility
    @Environment(\.markdownImageVisibility) private var imageVisibility
    @Environment(\.markdownHeadingVisibility) private var headingVisibility
    @Environment(\.markdownQuoteListVisibility) private var quoteVisibility
    @Environment(\.markdownThematicBreakVisibility) private var thematicBreakVisibility
    @Environment(\.markdownListVisibility) private var listVisibility

    private var inlineStyle = InlineMarkdownStyle()

    private var content: some View {
        ForEach(elements.indices, id: \.self) { index in
            switch elements[index] {
            case let .header(config):
                if headingVisibility != .hidden {
                    headerStyle.makeBody(configuration: config)
                }
            case let .quote(config):
                if quoteVisibility != .hidden {
                    quoteStyle.makeBody(configuration: config)
                }
            case let .code(config):
                if codeVisibility != .hidden {
                    codeStyle.makeBody(configuration: config)
                }
            case let .thematicBreak(config):
                if thematicBreakVisibility != .hidden {
                    thematicBreak.makeBody(configuration: config)
                }
            case let .image(config):
                if imageVisibility != .hidden {
                    imageStyle.makeBody(configuration: config)
                }
            case let .list(config):
                if listVisibility != .hidden {
                    listStyle.makeBody(configuration: config)
                }
            case let .paragraph(config):
                paragraphStyle.makeBody(configuration: config)
            case let .inline(config):
                inlineStyle.makeBody(configuration: config)
            }
        }
    }

    let elements: [MarkdownBlockElement]
    let paragraphSpacing: CGFloat?
    let isLazy: Bool

    private var stackAlignment: HorizontalAlignment {
        alignment == .leading
        ? .leading
        : alignment == .trailing
            ? .trailing
            : .center
    }

    init(elements: [MarkdownBlockElement], paragraphSpacing: CGFloat?, isLazy: Bool) {
        self.elements = elements
        self.paragraphSpacing = paragraphSpacing
        self.isLazy = isLazy
    }

    public var body: some View {
        if isLazy {
            if #available(iOS 14.0, *) {
                LazyVStack(alignment: stackAlignment, spacing: paragraphSpacing) { content }
            } else {
                VStack(alignment: stackAlignment, spacing: paragraphSpacing) { content }
            }
        } else {
            VStack(alignment: stackAlignment, spacing: paragraphSpacing) { content }
        }
    }
}

@available(iOS 14, *)
public struct LazyMarkdownText: View, MarkupWalker {
    private let content: MarkdownContent

    public init(_ markdown: String, source: URL? = nil, paragraphSpacing: CGFloat? = 20) {
        let elements = MarkdownTextBuilder(
            document: Document(parsing: markdown, source: source)
        ).blockElements

        content = .init(elements: elements, paragraphSpacing: paragraphSpacing, isLazy: true)
    }

    public var body: some View {
        content
    }
}

public struct MarkdownText: View, MarkupWalker {
    private let content: MarkdownContent

    public init(_ markdown: String, source: URL? = nil, paragraphSpacing: CGFloat? = 20) {
        let elements = MarkdownTextBuilder(
            document: Document(parsing: markdown, source: source)
        ).blockElements

        content = .init(elements: elements, paragraphSpacing: paragraphSpacing, isLazy: false)
    }

    public var body: some View {
        content
    }
}
