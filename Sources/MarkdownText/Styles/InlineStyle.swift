import SwiftUI

struct InlineMarkdownConfiguration {
    struct Content: View {
        @Environment(\.font) private var font
        @Environment(\.markdownStrongStyle) private var strong
        @Environment(\.markdownEmphasisStyle) private var emphasis
        @Environment(\.markdownStrikethroughStyle) private var strikethrough

        let components: [Component]

        var body: some View {
            components.reduce(into: Text("")) { result, component in
                if component.attributes.contains(.code) {
                    if #available(iOS 15, *) {
                        return result = result + component.text
                            .font(font?.monospaced() ?? .system(.body, design: .monospaced))
                    } else {
                        return result = result + component.text
                            .font(.system(.body, design: .monospaced))
                    }
                } else {
                    return result = result + component.text.apply(attributes: component.attributes)
                }
            }
        }
    }

    let components: [Component]

    public var label: some View {
        Content(components: components)
    }
}

struct InlineMarkdownStyle {
    func makeBody(configuration: InlineMarkdownConfiguration) -> some View {
        configuration.label
    }
}
