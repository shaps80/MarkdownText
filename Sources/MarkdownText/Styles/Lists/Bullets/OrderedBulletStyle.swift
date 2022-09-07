import SwiftUI

public protocol OrderedListBulletMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = OrderedListBulletMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyOrderedListBulletMarkdownStyle: OrderedListBulletMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: OrderedListBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct OrderedListBulletMarkdownConfiguration {
    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        let order: Int

        var body: some View {
            Text("\(order).")
                .frame(minWidth: reservedWidth)
        }
    }

    public let order: Int
    
    public var label: some View {
        Label(order: order)
    }
}

public struct NumericallyOrderedListBulletMarkdownStyle: OrderedListBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension OrderedListBulletMarkdownStyle where Self == NumericallyOrderedListBulletMarkdownStyle {
    static var numerical: Self { .init() }
}

private struct OrderedBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyOrderedListBulletMarkdownStyle = .init(NumericallyOrderedListBulletMarkdownStyle())
}

public extension EnvironmentValues {
    var markdownOrderedListBulletStyle: AnyOrderedListBulletMarkdownStyle {
        get { self[OrderedBulletMarkdownEnvironmentKey.self] }
        set { self[OrderedBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownOrderedListBulletStyle<S>(_ style: S) -> some View where S: OrderedListBulletMarkdownStyle {
        environment(\.markdownOrderedListBulletStyle, .init(style))
    }
}
