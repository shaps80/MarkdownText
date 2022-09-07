import Foundation

// Used during parsing to store all discovered block elements
enum MarkdownBlockElement {
    case heading(HeadingMarkdownConfiguration)
    case paragraph(ParagraphMarkdownConfiguration)
    case quote(QuoteMarkdownConfiguration)
    case list(ListStyleMarkdownConfiguration)
    case code(CodeMarkdownConfiguration)
    case image(ImageMarkdownConfiguration)
    case thematicBreak(ThematicMarkdownConfiguration)
    case inline(InlineMarkdownConfiguration)
}
