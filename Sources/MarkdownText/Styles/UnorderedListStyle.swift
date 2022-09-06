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
    public let items: [UnorderedItem]
}

public struct DefaultUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    struct Content: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.lineSpacing) private var spacing

        var bullet: Text
        var items: [UnorderedItem]

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(items.indices, id: \.self) { index in
                    Backport.Label {
                        items[index].content
                    } icon: {
                        bullet
                            .frame(minWidth: reservedWidth)
                    }
                }
            }
        }
    }

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        Content(bullet: Text("–"), items: configuration.items)
    }
}

public struct NoUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension UnorderedListMarkdownStyle where Self == NoUnorderedListMarkdownStyle {
    static var hidden: Self { NoUnorderedListMarkdownStyle() }
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
