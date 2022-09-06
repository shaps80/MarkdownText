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
    public let items: [OrderedItem]
}

public struct DefaultOrderedListMarkdownStyle: OrderedListMarkdownStyle {
    struct Content: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.lineSpacing) private var spacing

        var items: [OrderedItem]

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(items.indices, id: \.self) { index in
                    Backport.Label {
                        items[index].label
                    } icon: {
                        Text("\(index + 1).")
                            .frame(minWidth: reservedWidth)
                    }
                }
            }
        }
    }

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        Content(items: configuration.items)
    }
}

public struct NoOrderedListMarkdownStyle: OrderedListMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension OrderedListMarkdownStyle where Self == NoOrderedListMarkdownStyle {
    static var hidden: Self { NoOrderedListMarkdownStyle() }
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
