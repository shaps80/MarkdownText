import SwiftUI

public protocol OrderedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = OrderedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyOrderedListMarkdownStyle: OrderedListMarkdownStyle {
    var label: (OrderedListMarkdownConfiguration) -> AnyView
    init<S: OrderedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct OrderedListMarkdownConfiguration {
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

public struct DefaultOrderedListMarkdownStyle: OrderedListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension OrderedListMarkdownStyle where Self == DefaultOrderedListMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct OrderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyOrderedListMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownOrderedListStyle: AnyOrderedListMarkdownStyle {
        get { self[OrderedListMarkdownEnvironmentKey.self] }
        set { self[OrderedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownOrderedListStyle<S>(_ style: S) -> some View where S: OrderedListMarkdownStyle {
        environment(\.markdownOrderedListStyle, AnyOrderedListMarkdownStyle(style))
    }
}
