import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to ordered item markdown elements
public protocol OrderedListItemMarkdownStyle {
    associatedtype Body: View
    /// The properties of a ordered item markdown element
    typealias Configuration = OrderedListItemMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyOrderedListItemMarkdownStyle: OrderedListItemMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: OrderedListItemMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a ordered item markdown element
public struct OrderedListItemMarkdownConfiguration {
    private struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownOrderedListBulletStyle) private var bulletStyle
        @Environment(\.markdownOrderedListItemBulletVisibility) private var bulletVisibility

        public let level: Int
        public let bullet: OrderedListBulletMarkdownConfiguration
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
    public let bullet: OrderedListBulletMarkdownConfiguration
    /// The content configuration for this element
    public let content: ParagraphMarkdownConfiguration
    /// Returns a default ordered item markdown representation
    public var label: some View {
        Label(level: level, bullet: bullet, paragraph: content)
    }
}

/// The default ordered item style
public struct DefaultOrderedListItemMarkdownStyle: OrderedListItemMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension OrderedListItemMarkdownStyle where Self == DefaultOrderedListItemMarkdownStyle {
    /// The default ordered item style
    static var `default`: Self { .init() }
}

private struct OrderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyOrderedListItemMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current ordered item markdown style
    var markdownOrderedListItemStyle: AnyOrderedListItemMarkdownStyle {
        get { self[OrderedListMarkdownEnvironmentKey.self] }
        set { self[OrderedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for ordered item markdown elements
    func markdownOrderedListItemStyle<S>(_ style: S) -> some View where S: OrderedListItemMarkdownStyle {
        environment(\.markdownOrderedListItemStyle, AnyOrderedListItemMarkdownStyle(style))
    }
}
