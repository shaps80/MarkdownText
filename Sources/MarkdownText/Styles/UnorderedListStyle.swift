import SwiftUI

public protocol UnorderedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyUnorderedListMarkdownStyle {
    var label: (UnorderedListMarkdownConfiguration) -> AnyView
    init<S: UnorderedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct UnorderedListMarkdownConfiguration {
    public let items: [UnorderedItem]
}

public struct DefaultUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    var bullet: AnyView
    var color: Color?

    struct Content: View {
        @Backport.ScaledMetric(wrappedValue: 30) private var padding
        @Backport.ScaledMetric(wrappedValue: 6) private var spacing

        var bullet: AnyView
        var color: Color?
        var items: [UnorderedItem]

        var body: some View {
            AnyView(
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(items.indices, id: \.self) { index in
                        Backport.Label {
                            items[index].content
                        } icon: {
                            bullet
                        }
                    }
                }
            )
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        Content(bullet: bullet, color: color, items: configuration.items)
    }
}

public struct NoUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension UnorderedListMarkdownStyle where Self == NoUnorderedListMarkdownStyle {
    static var hidden: Self { NoUnorderedListMarkdownStyle() }
}

public extension UnorderedListMarkdownStyle where Self == DefaultUnorderedListMarkdownStyle {
    static var `default`: Self { .default(prefix: "–") }
    static func `default`(prefix: String = "–", color: Color? = nil) -> Self {
        .init(bullet: AnyView(Text(prefix)), color: color)
    }
    static func `default`(image: Image, color: Color? = nil) -> Self {
        .init(bullet: AnyView(image), color: color)
    }
}

private struct UnorderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyUnorderedListMarkdownStyle(.default)
}

extension EnvironmentValues {
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
