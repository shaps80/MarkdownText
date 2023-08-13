import SwiftUI

/// A type that applies a custom highlighter to code block
public protocol MarkdownCodeSyntaxHighlighterStyle {
    func highlightCode(_ code: String, language: String?) -> Text
}


/// A plain text code syntax highlighter.
public struct PlainTextCodeSyntaxHighlighterStyle: MarkdownCodeSyntaxHighlighterStyle {

    public func highlightCode(_ code: String, language: String?) -> Text {
        Text(code)
    }
}

extension MarkdownCodeSyntaxHighlighterStyle where Self == PlainTextCodeSyntaxHighlighterStyle {
    /// A plain text code syntax highlighter.
    public static var plainText: Self {
        PlainTextCodeSyntaxHighlighterStyle()
    }
}

public extension View {
    /// Sets the style for code block markdown elements
    func markdownCodeSyntaxHighlighter(_ style: some MarkdownCodeSyntaxHighlighterStyle) -> some View {
        environment(\.markdownCodeSyntaxHighlighter, style)
    }
}

private struct MarkdownCodeSyntaxHighlighterEnvironmentKey: EnvironmentKey {
    static let defaultValue: any MarkdownCodeSyntaxHighlighterStyle = PlainTextCodeSyntaxHighlighterStyle()
}

public extension EnvironmentValues {
    /// The current code block highlighter style
    var markdownCodeSyntaxHighlighter: any MarkdownCodeSyntaxHighlighterStyle {
        get { self[MarkdownCodeSyntaxHighlighterEnvironmentKey.self] }
        set { self[MarkdownCodeSyntaxHighlighterEnvironmentKey.self] = newValue }
    }
}