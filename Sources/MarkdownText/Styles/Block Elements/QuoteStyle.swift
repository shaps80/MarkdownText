import SwiftUI

/// A type that applies a custom appearance to quote markdown elements
public protocol QuoteMarkdownStyle {
    associatedtype Body: View
    /// The properties of a quote markdown element
    typealias Configuration = QuoteMarkdownConfiguration
    /// Creates a view that represents the body of a label
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

/// The properties of a quote markdown element
public struct QuoteMarkdownConfiguration {
    /// The content for this element
    ///
    /// You can use this to maintain the existing heading style:
    ///
    ///     content.label // maintains its font style
    ///         .padding()
    ///         .background {
    ///             Color.primary
    ///                 .opacity(0.05)
    ///                 .cornerRadius(13)
    ///         }
    public let content: ParagraphMarkdownConfiguration

    private struct Label: View {
        let paragraph: ParagraphMarkdownConfiguration

        var body: some View {
            paragraph.label
        }
    }

    /// Returns a default quote markdown representation
    public var label: some View {
        Label(paragraph: content)
    }
}

public struct DefaultQuoteMarkdownStyle: QuoteMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension QuoteMarkdownStyle where Self == DefaultQuoteMarkdownStyle {
    /// The default quote style
    static var `default`: Self { .init() }
}

private struct QuoteMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyQuoteMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current quote markdown style
    var markdownQuoteStyle: AnyQuoteMarkdownStyle {
        get { self[QuoteMarkdownEnvironmentKey.self] }
        set { self[QuoteMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for quote markdown elements
    func markdownQuoteStyle<S>(_ style: S) -> some View where S: QuoteMarkdownStyle {
        environment(\.markdownQuoteStyle, AnyQuoteMarkdownStyle(style))
    }
}
