import SwiftUI

public protocol QuoteMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = QuoteMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyQuoteMarkdownStyle: QuoteMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: QuoteMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct QuoteMarkdownConfiguration {
    public let paragraph: ParagraphMarkdownConfiguration

    private struct Label: View {
        let paragraph: ParagraphMarkdownConfiguration

        var body: some View {
            paragraph.label
        }
    }

    public var label: some View {
        Label(paragraph: paragraph)
    }
}

public struct DefaultQuoteMarkdownStyle: QuoteMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension QuoteMarkdownStyle where Self == DefaultQuoteMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct QuoteMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyQuoteMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownQuoteStyle: AnyQuoteMarkdownStyle {
        get { self[QuoteMarkdownEnvironmentKey.self] }
        set { self[QuoteMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownQuoteStyle<S>(_ style: S) -> some View where S: QuoteMarkdownStyle {
        environment(\.markdownQuoteStyle, AnyQuoteMarkdownStyle(style))
    }
}
