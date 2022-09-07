import SwiftUI

public protocol UnorderedListItemMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedListItemMarkdownConfiguration
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

public struct UnorderedListItemMarkdownConfiguration {
    public let level: Int
    public let bullet: UnorderedBulletMarkdownConfiguration
    public let paragraph: ParagraphMarkdownConfiguration

    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownUnorderedBulletStyle) private var bulletStyle

        public let level: Int
        public let bullet: UnorderedBulletMarkdownConfiguration
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

public struct DefaultUnorderedListItemMarkdownStyle: UnorderedListItemMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedListItemMarkdownStyle where Self == DefaultUnorderedListItemMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct UnorderedListItemMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyUnorderedListItemMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownUnorderedListItemStyle: AnyUnorderedListItemMarkdownStyle {
        get { self[UnorderedListItemMarkdownEnvironmentKey.self] }
        set { self[UnorderedListItemMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedListItemStyle<S>(_ style: S) -> some View where S: UnorderedListItemMarkdownStyle {
        environment(\.markdownUnorderedListItemStyle, AnyUnorderedListItemMarkdownStyle(style))
    }
}
