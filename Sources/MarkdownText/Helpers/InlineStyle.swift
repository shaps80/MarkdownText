import SwiftUI

struct InlineMarkdownConfiguration {
    struct Label: View {
        @Environment(\.font) private var font
        @Environment(\.markdownStrongStyle) private var strong
        @Environment(\.markdownEmphasisStyle) private var emphasis
        @Environment(\.markdownStrikethroughStyle) private var strikethrough
        @Environment(\.markdownInlineCodeStyle) private var code
        @Environment(\.markdownInlineLinkStyle) private var link

        let elements: [MarkdownInlineElement]

        var body: some View {
            elements.reduce(into: Text("")) { result, component in
                if component.attributes.contains(.code) {
                    return result = result + code.makeBody(
                        configuration: .init(code: component.content, font: font)
                    )
                } else {
                    return result = result + Text(component.content).apply(
                        strong: strong,
                        emphasis: emphasis,
                        strikethrough: strikethrough,
                        link: link,
                        attributes: component.attributes
                    )
                }
            }
        }
    }

    public let elements: [MarkdownInlineElement]

    public var label: some View {
        Label(elements: elements)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct InlineMarkdownStyle {
    func makeBody(configuration: InlineMarkdownConfiguration) -> some View {
        configuration.label
    }
}
