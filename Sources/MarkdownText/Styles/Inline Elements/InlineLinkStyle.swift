import SwiftUI

/// A type that applies a custom appearance to inline link markdown elements
public protocol InlineLinkMarkdownStyle {
    /// The properties of an inline link markdown element
    typealias Configuration = InlineLinkMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Text
}

/// The properties of an inline link markdown element
public struct InlineLinkMarkdownConfiguration {
    /// The textual content for this element
    public let content: Text
    /// Returns a default inline link markdown representation
    public var label: Text { content }
}

/// An inline link style that sets the `foregroundColor` to the view's current `accentColor`
public struct DefaultInlineLinkMarkdownStyle: InlineLinkMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
            .foregroundColor(.accentColor)
    }
}

public extension InlineLinkMarkdownStyle where Self == DefaultInlineLinkMarkdownStyle {
    /// An inline link style that sets the `foregroundColor` to the view's current `accentColor`
    ///
    /// - note: Inline links are always **non-interactive**.
    static var nonInteractiveInline: Self { .init() }
}

private struct InlineLinkMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: InlineLinkMarkdownStyle = DefaultInlineLinkMarkdownStyle.nonInteractiveInline
}

public extension EnvironmentValues {
    /// The current inline link markdown style
    var markdownInlineLinkStyle: InlineLinkMarkdownStyle {
        get { self[InlineLinkMarkdownEnvironmentKey.self] }
        set { self[InlineLinkMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for inline link markdown elements
    func markdownInlineLinkStyle<S>(_ style: S) -> some View where S: InlineLinkMarkdownStyle {
        environment(\.markdownInlineLinkStyle, style)
    }
}
