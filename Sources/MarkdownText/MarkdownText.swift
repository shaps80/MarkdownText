import SwiftUI
import Markdown

private struct MarkdownContent: View {
    @Environment(\.multilineTextAlignment) private var alignment
    @Environment(\.headerMarkdownStyle) private var headerStyle
    @Environment(\.paragraphMarkdownStyle) private var paragraphStyle
    @Environment(\.quoteMarkdownStyle) private var quoteStyle
    @Environment(\.codeMarkdownStyle) private var codeStyle
    @Environment(\.thematicMarkdownStyle) private var thematicStyle
    @Environment(\.orderedListMarkdownStyle) private var orderedStyle
    @Environment(\.unorderedListMarkdownStyle) private var unorderedStyle
    @Environment(\.checkedListMarkdownStyle) private var checkedStyle
    @Environment(\.imageMarkdownStyle) private var imageStyle
    @Environment(\.inlineMarkdownStyle) private var inlineStyle

    private var content: some View {
        ForEach(elements.indices, id: \.self) { index in
            switch elements[index] {
            case let .header(config):
                headerStyle.label(config)
            case let .paragraph(config):
                paragraphStyle.label(config)
            case let .inline(config):
                inlineStyle.label(config)
            case let .quote(config):
                quoteStyle.label(config)
            case let .orderedList(config):
                orderedStyle.label(config)
            case let .unorderedList(config):
                unorderedStyle.label(config)
            case let .checkedList(config):
                checkedStyle.label(config)
            case let .code(config):
                codeStyle.label(config)
            case let .thematicBreak(config):
                thematicStyle.label(config)
            case let .image(config):
                imageStyle.label(config)
            }
        }
    }
    

    let elements: [MarkdownElement]
    let paragraphSpacing: CGFloat?
    let isLazy: Bool

    private var stackAlignment: HorizontalAlignment {
        alignment == .leading
        ? .leading
        : alignment == .trailing
            ? .trailing
            : .center
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

    public init(_ markdown: String, paragraphSpacing: CGFloat? = 20) {
        let elements = TextBuilder(
            document: Document(parsing: markdown)
        ).elements

        content = .init(elements: elements, paragraphSpacing: paragraphSpacing, isLazy: true)
    }

    public var body: some View {
        content
    }
}

public struct MarkdownText: View, MarkupWalker {
    private let content: MarkdownContent

    public init(_ markdown: String, paragraphSpacing: CGFloat? = 20) {
        let elements = TextBuilder(
            document: Document(parsing: markdown, options: [.parseSymbolLinks, .parseSymbolLinks])
        ).elements

        content = .init(elements: elements, paragraphSpacing: paragraphSpacing, isLazy: false)
    }

    public var body: some View {
        content
    }
}

struct MarkdownText_Previews: PreviewProvider {
    static let text = """
    # Large title

    ## Title 1
    ### Title 2
    #### Title 3
    ##### Headline
    ###### Subheadline

    A opening paragraph from [Apple](apple.com)

    Some `inline` code

    ```
    func foo() { }
    ```

    > A blockquote
    > with multiple lines

    *Emphasized* **strong**
    A soft break

    1. First list item
    3. Second list item

    - An
    - unordered
    - list

    Another paragraph

    - [ ] Unchecked
    - [x] Checked
    """

    static var previews: some View {
        MarkdownText(text)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
