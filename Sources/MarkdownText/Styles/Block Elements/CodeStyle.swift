import SwiftUI

/// A type that applies a custom appearance to code block markdown elements
public protocol CodeMarkdownStyle {
    associatedtype Body: View
    /// The properties of an code block markdown element
    typealias Configuration = CodeMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyCodeMarkdownStyle: CodeMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: CodeMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a code block markdown element
public struct CodeMarkdownConfiguration {
    /// The raw code for this element
    public let code: String
    /// The code language for this element
    public let language: String?

    struct Label: View {
        @Environment(\.font) private var font

        let code: String
        let language: String?

        var body: some View {
            if #available(iOS 15, *) {
                Text(code.trimmingCharacters(in: .newlines))
                    .font(
                        font?.monospaced()
                        ?? .system(.body, design: .monospaced)
                    )
            } else {
                Text(code.trimmingCharacters(in: .newlines))
                    .font(.system(.body, design: .monospaced))
            }
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
    static let defaultValue = AnyCodeMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current code block markdown style
    var markdownCodeStyle: AnyCodeMarkdownStyle {
        get { self[CodeMarkdownEnvironmentKey.self] }
        set { self[CodeMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for code block markdown elements
    func markdownCodeStyle<S>(_ style: S) -> some View where S: CodeMarkdownStyle {
        environment(\.markdownCodeStyle, AnyCodeMarkdownStyle(style))
    }
}
