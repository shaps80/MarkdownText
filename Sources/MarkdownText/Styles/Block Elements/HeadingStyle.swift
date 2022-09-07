import SwiftUI

/// A type that applies a custom appearance to heading markdown elements
public protocol HeadingMarkdownStyle {
    associatedtype Body: View
    /// The properties of a heading markdown element
    typealias Configuration = HeadingMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyHeadingMarkdownStyle: HeadingMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: HeadingMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a heading markdown element
public struct HeadingMarkdownConfiguration {
    /// The header level (e.g. `H2` would have a level of `2`)
    public let level: Int
    /// The content for this heading
    ///
    /// You can use this to maintain the existing heading style:
    ///
    ///     content.label // maintains its font style
    ///         .foregroundColor(.accentColor)
    let content: InlineMarkdownConfiguration

    /// The preferred text tyle for this heading.
    public var preferredStyle: Font.TextStyle {
        switch level {
        case 1: return .title
        case 2:
            if #available(iOS 14.0, *) {
                return .title2
            } else {
                return .title
            }
        case 3:
            if #available(iOS 14.0, *) {
                return .title3
            } else {
                return .title
            }
        case 4: return .headline
        default: return .subheadline
        }
    }

    private struct Label: View {
        public let level: Int
        let content: InlineMarkdownConfiguration

        var body: some View {
            content.label
        }
    }

    /// Returns a default heading markdown representation
    public var label: some View {
        Label(level: level, content: content)
            .font(.system(preferredStyle).weight(.bold))
    }
}

/// A heading style that applies a preferred font style based on the heading level
public struct DefaultHeadingMarkdownStyle: HeadingMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension HeadingMarkdownStyle where Self == DefaultHeadingMarkdownStyle {
    /// A heading style that applies a preferred font style based on the heading level
    static var `default`: Self { .init() }
}

private struct HeadingMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyHeadingMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current heading markdown style
    var markdownHeadingStyle: AnyHeadingMarkdownStyle {
        get { self[HeadingMarkdownEnvironmentKey.self] }
        set { self[HeadingMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for heading markdown elements
    func markdownHeadingStyle<S>(_ style: S) -> some View where S: HeadingMarkdownStyle {
        environment(\.markdownHeadingStyle, AnyHeadingMarkdownStyle(style))
    }
}
