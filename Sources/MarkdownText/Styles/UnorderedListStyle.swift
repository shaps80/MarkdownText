import SwiftUI

public protocol UnorderedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    var label: (UnorderedListMarkdownConfiguration) -> AnyView
    init<S: UnorderedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct UnorderedListMarkdownConfiguration {
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
            Array(repeating: "     ", count: level).joined()
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

public struct DefaultUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedListMarkdownStyle where Self == DefaultUnorderedListMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct UnorderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyUnorderedListMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownUnorderedListStyle: AnyUnorderedListMarkdownStyle {
        get { self[UnorderedListMarkdownEnvironmentKey.self] }
        set { self[UnorderedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedListStyle<S>(_ style: S) -> some View where S: UnorderedListMarkdownStyle {
        environment(\.markdownUnorderedListStyle, AnyUnorderedListMarkdownStyle(style))
    }
}
