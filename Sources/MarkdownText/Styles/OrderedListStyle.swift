import SwiftUI

public protocol OrderedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = OrderedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyOrderedListMarkdownStyle {
    var label: (OrderedListMarkdownConfiguration) -> AnyView
    init<S: OrderedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct OrderedListMarkdownConfiguration {
    public let items: [OrderedItem]
}

public struct DefaultOrderedListMarkdownStyle: OrderedListMarkdownStyle {
    private let padding = UIFontMetrics(forTextStyle: .body)
        .scaledValue(for: 30)

    var startOrder: Int = 1
    var color: Color?

    struct Content: View {
        @Backport.ScaledMetric(wrappedValue: 30) private var padding
        @Backport.ScaledMetric(wrappedValue: 6) private var spacing

        var startOrder: Int = 1
        var color: Color?
        var items: [OrderedItem]

        var body: some View {
            AnyView(
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(items.indices, id: \.self) { index in
                        items[index].content
                            .padding(.leading, padding)
                            .overlay(
                                Text("\(index + startOrder).")
                                    .foregroundColor(color)
                                , alignment: .init(horizontal: .leading, vertical: .firstTextBaseline))
                    }
                }
            )
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        Content(startOrder: startOrder, color: color, items: configuration.items)
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
    static var `default`: Self { .init(color: nil) }
    static func `default`(startOrder: Int = 1, color: Color? = nil) -> Self { .init(startOrder: startOrder, color: color) }
}

private struct OrderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyOrderedListMarkdownStyle(.default)
}

extension EnvironmentValues {
    var orderedListMarkdownStyle: AnyOrderedListMarkdownStyle {
        get { self[OrderedListMarkdownEnvironmentKey.self] }
        set { self[OrderedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func orderedListStyle<S>(_ style: S) -> some View where S: OrderedListMarkdownStyle {
        environment(\.orderedListMarkdownStyle, AnyOrderedListMarkdownStyle(style))
    }
}
