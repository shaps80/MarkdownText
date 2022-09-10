import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to unordered item markdown elements
public protocol UnorderedListItemMarkdownStyle {
    associatedtype Body: View
    /// The properties of an unordered item markdown element
    typealias Configuration = UnorderedListItemMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedListItemMarkdownStyle: UnorderedListItemMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: UnorderedListItemMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of an unordered item markdown element
public struct UnorderedListItemMarkdownConfiguration {
    private struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownUnorderedListBulletStyle) private var bulletStyle
        @Environment(\.markdownUnorderedListItemBulletVisibility) private var bulletVisibility

        public let level: Int
        public let bullet: UnorderedListBulletMarkdownConfiguration
        public let paragraph: ParagraphMarkdownConfiguration

        private var space: String {
            Array(repeating: "    ", count: level).joined()
        }

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(space)

                Backport.Label {
                    paragraphStyle.makeBody(configuration: paragraph)
                } icon: {
                    if bulletVisibility != .hidden {
                        bulletStyle.makeBody(configuration: bullet)
                            .frame(minWidth: reservedWidth)
                    }
                }
                .backport.labelStyle(.list)
            }
        }
    }

    /// An integer value representing this element's indentation level in the list
    public let level: Int
    /// The bullet configuration for this element
    public let bullet: UnorderedListBulletMarkdownConfiguration
    /// The content configuration for this element
    public let content: ParagraphMarkdownConfiguration
    /// Returns a default unordered item markdown representation
    public var label: some View {
        Label(level: level, bullet: bullet, paragraph: content)
    }
}

/// The default unordered item style
public struct DefaultUnorderedListItemMarkdownStyle: UnorderedListItemMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedListItemMarkdownStyle where Self == DefaultUnorderedListItemMarkdownStyle {
    /// The default unordered item style
    static var `default`: Self { .init() }
}

private struct UnorderedListItemMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyUnorderedListItemMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current unordered item markdown style
    var markdownUnorderedListItemStyle: AnyUnorderedListItemMarkdownStyle {
        get { self[UnorderedListItemMarkdownEnvironmentKey.self] }
        set { self[UnorderedListItemMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for unordered item markdown elements
    func markdownUnorderedListItemStyle<S>(_ style: S) -> some View where S: UnorderedListItemMarkdownStyle {
        environment(\.markdownUnorderedListItemStyle, AnyUnorderedListItemMarkdownStyle(style))
    }
}
