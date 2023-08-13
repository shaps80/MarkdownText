import SwiftUI

/// A type that applies a custom appearance to code block markdown elements
public protocol CodeMarkdownStyle {
    associatedtype Body: View
    /// The properties of an code block markdown element
    typealias Configuration = CodeMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a code block markdown element
public struct CodeMarkdownConfiguration {
    /// The raw code for this element
    public let code: String
    /// The code language for this element
    public let language: String?

    struct Label: View {
        @Environment(\.font) private var font
        @Environment(\.markdownCodeSyntaxHighlighter) private var markdownCodeSyntaxHighlighter

        let code: String
        let language: String?

        var body: some View {
            let text = markdownCodeSyntaxHighlighter
                    .highlightCode(code.trimmingCharacters(in: .newlines), language: language)
            #if os(macOS)
            if #available(macOS 12, *) {
                text
                    .font(
                        font?.monospaced()
                        ?? .system(.body, design: .monospaced)
                    )
            } else {
                text
                    .font(.system(.body, design: .monospaced))
            }
            #elseif os(iOS)
            if #available(iOS 15, *) {
                text
                    .font(
                        font?.monospaced()
                            ?? .system(.body, design: .monospaced)
                    )
            } else {
                text
                    .font(.system(.body, design: .monospaced))
            }
            #else
            text
                .font(.system(.body, design: .monospaced))
            #endif
        }
    }

    /// Returns a default code block markdown representation
    public var label: some View {
        Label(code: code, language: language)
            .font(.callout)
            .lineSpacing(5)
            .environment(\.layoutDirection, .leftToRight)
    }
}

/// A code block style that applies a monospaced representation to its content and wraps it in a horizontal `ScrollView`
public struct DefaultCodeMarkdownStyle: CodeMarkdownStyle {
    var axes: Axis.Set
    var showsIndicators: Bool

    /// Creates a new instance of this style
    /// - Parameters:
    ///   - axes: The scrollable axes
    ///   - showsIndicators: If `true`, scroll indicators will be visible when required
    public init(_ axes: Axis.Set = .horizontal, showsIndicators: Bool = false) {
        self.axes = axes
        self.showsIndicators = showsIndicators
    }

    public func makeBody(configuration: Configuration) -> some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            configuration.label
        }
    }
}

public extension CodeMarkdownStyle where Self == DefaultCodeMarkdownStyle {
    /// A code block style that applies a monospaced representation to its content and wraps it in a horizontal `ScrollView`
    static var `default`: Self { .init() }

    /// A code block style that applies a monospaced representation to its content and wraps it in a horizontal `ScrollView`
    /// - Parameters:
    ///   - axes: The scrollable axes
    ///   - showsIndicators: If `true`, scroll indicators will be visible when required
    static func `default`(_ axes: Axis.Set, showsIndicators: Bool = false) -> Self {
        .init(axes, showsIndicators: showsIndicators)
    }
}

private struct CodeMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: any CodeMarkdownStyle = DefaultCodeMarkdownStyle()
}

public extension EnvironmentValues {
    /// The current code block markdown style
    var markdownCodeStyle: any CodeMarkdownStyle {
        get { self[CodeMarkdownEnvironmentKey.self] }
        set { self[CodeMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for code block markdown elements
    func markdownCodeStyle(_ style: some CodeMarkdownStyle) -> some View {
        environment(\.markdownCodeStyle, style)
    }
}
