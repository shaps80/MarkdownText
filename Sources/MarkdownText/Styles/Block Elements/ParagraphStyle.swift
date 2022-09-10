import SwiftUI

/// A type that applies a custom appearance to paragraph markdown elements
public protocol ParagraphMarkdownStyle {
    associatedtype Body: View
    /// The properties of a paragraph markdown element
    typealias Configuration = ParagraphMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyParagraphMarkdownStyle: ParagraphMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: ParagraphMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a paragraph markdown element
public struct ParagraphMarkdownConfiguration {
    /// The content for this element
    ///
    /// You can use this to maintain the existing paragraph style:
    ///
    ///     content.label // maintains the default style
    ///         .lineSpacing(20)
    let content: InlineMarkdownConfiguration

    private struct Label: View {
        let content: InlineMarkdownConfiguration

        var body: some View {
            content.label
        }
    }

    /// Returns a default heading markdown representation
    public var label: some View {
        Label(content: content)
    }
}

/// The default paragraph style
public struct DefaultParagraphMarkdownStyle: ParagraphMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ParagraphMarkdownStyle where Self == DefaultParagraphMarkdownStyle {
    /// The default paragraph style
    static var `default`: Self { .init() }
}

private struct ParagraphMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyParagraphMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current paragraph markdown style
    var markdownParagraphStyle: AnyParagraphMarkdownStyle {
        get { self[ParagraphMarkdownEnvironmentKey.self] }
        set { self[ParagraphMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for paragraph markdown elements
    func markdownParagraphStyle<S>(_ style: S) -> some View where S: ParagraphMarkdownStyle {
        environment(\.markdownParagraphStyle, AnyParagraphMarkdownStyle(style))
    }
}
