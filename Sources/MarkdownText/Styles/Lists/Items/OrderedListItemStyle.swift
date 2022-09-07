import SwiftUI

public protocol OrderedListItemMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = OrderedListItemMarkdownConfiguration
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

public struct OrderedListItemMarkdownConfiguration {
    public let level: Int
    public let bullet: OrderedBulletMarkdownConfiguration
    public let paragraph: ParagraphMarkdownConfiguration

    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownOrderedBulletStyle) private var bulletStyle

        public let level: Int
        public let bullet: OrderedBulletMarkdownConfiguration
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
                    bulletStyle.makeBody(configuration: bullet)
                        .frame(minWidth: reservedWidth)
                }
            }
        }
    }

    public var label: some View {
        Label(level: level, bullet: bullet, paragraph: paragraph)
    }
}

public struct DefaultOrderedListItemMarkdownStyle: OrderedListItemMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension OrderedListItemMarkdownStyle where Self == DefaultOrderedListItemMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct OrderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyOrderedListItemMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownOrderedListItemStyle: AnyOrderedListItemMarkdownStyle {
        get { self[OrderedListMarkdownEnvironmentKey.self] }
        set { self[OrderedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownOrderedListItemStyle<S>(_ style: S) -> some View where S: OrderedListItemMarkdownStyle {
        environment(\.markdownOrderedListItemStyle, AnyOrderedListItemMarkdownStyle(style))
    }
}
