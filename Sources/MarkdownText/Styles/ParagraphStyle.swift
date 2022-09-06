import SwiftUI

public protocol ParagraphMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ParagraphMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyParagraphMarkdownStyle: ParagraphMarkdownStyle {
    var label: (ParagraphMarkdownConfiguration) -> AnyView
    init<S: ParagraphMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct ParagraphMarkdownConfiguration {
    let inline: InlineMarkdownConfiguration
}

public struct NoParagraphMarkdownStyle: ParagraphMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension ParagraphMarkdownStyle where Self == NoParagraphMarkdownStyle {
    static var hidden: Self { NoParagraphMarkdownStyle() }
}

public struct DefaultParagraphMarkdownStyle: ParagraphMarkdownStyle {
    struct Content: View {
        let configuration: InlineMarkdownConfiguration

        var body: some View {
            InlineMarkdownStyle()
                .makeBody(configuration: configuration)
        }
    }

    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.inline.label
    }
}

public extension ParagraphMarkdownStyle where Self == DefaultParagraphMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct ParagraphMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyParagraphMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownParagraphStyle: AnyParagraphMarkdownStyle {
        get { self[ParagraphMarkdownEnvironmentKey.self] }
        set { self[ParagraphMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownParagraphStyle<S>(_ style: S) -> some View where S: ParagraphMarkdownStyle {
        environment(\.markdownParagraphStyle, AnyParagraphMarkdownStyle(style))
    }
}
