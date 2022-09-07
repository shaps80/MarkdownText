import SwiftUI

struct InlineMarkdownConfiguration {
    struct Label: View {
        @Environment(\.font) private var font
        @Environment(\.markdownStrongStyle) private var strong
        @Environment(\.markdownEmphasisStyle) private var emphasis
        @Environment(\.markdownStrikethroughStyle) private var strikethrough
        @Environment(\.markdownInlineCodeStyle) private var code
        @Environment(\.markdownInlineLinkStyle) private var link

        let components: [Component]

        var body: some View {
            components.reduce(into: Text("")) { result, component in
                if component.attributes.contains(.code) {
                    return result = result + code.makeBody(
                        configuration: .init(code: component.text, font: font)
                    )
                } else {
                    return result = result + Text(component.text).apply(
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

    let components: [Component]

    public var label: some View {
        Label(components: components)
    }
}

struct InlineMarkdownStyle {
    func makeBody(configuration: InlineMarkdownConfiguration) -> some View {
        configuration.label
    }
}
