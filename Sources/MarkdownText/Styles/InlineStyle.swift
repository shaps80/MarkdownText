import SwiftUI

public protocol InlineMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = InlineMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyInlineMarkdownStyle {
    var label: (InlineMarkdownConfiguration) -> AnyView
    init<S: InlineMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct InlineMarkdownConfiguration {
    struct Content: View {
        @Environment(\.font) private var font

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

    public let components: [Component]
    public var label: some View {
        Content(components: components)
    }
}

public struct DefaultInlineMarkdownStyle: InlineMarkdownStyle {
    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension InlineMarkdownStyle where Self == DefaultInlineMarkdownStyle {
    static var `default`: Self { .init() }
}

public struct PlainInlineMarkdownStyle: InlineMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.components.reduce(into: Text("")) { result, component in
            result = result + component.text
        }
    }
}

public extension InlineMarkdownStyle where Self == PlainInlineMarkdownStyle {
    static var plain: Self { .init() }
}

private struct InlineMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyInlineMarkdownStyle(.default)
}

extension EnvironmentValues {
    var markdownInlineStyle: AnyInlineMarkdownStyle {
        get { self[InlineMarkdownEnvironmentKey.self] }
        set { self[InlineMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownInlineStyle<S>(_ style: S) -> some View where S: InlineMarkdownStyle {
        environment(\.markdownInlineStyle, AnyInlineMarkdownStyle(style))
    }
}
