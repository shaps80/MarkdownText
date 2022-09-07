import SwiftUI

public protocol OrderedBulletMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = OrderedBulletMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyOrderedBulletMarkdownStyle: OrderedBulletMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: OrderedBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct OrderedBulletMarkdownConfiguration {
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

public struct NumericallyOrderedBulletMarkdownStyle: OrderedBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension OrderedBulletMarkdownStyle where Self == NumericallyOrderedBulletMarkdownStyle {
    static var numerical: Self { .init() }
}

private struct OrderedBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyOrderedBulletMarkdownStyle = .init(NumericallyOrderedBulletMarkdownStyle())
}

public extension EnvironmentValues {
    var markdownOrderedBulletStyle: AnyOrderedBulletMarkdownStyle {
        get { self[OrderedBulletMarkdownEnvironmentKey.self] }
        set { self[OrderedBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownOrderedBulletStyle<S>(_ style: S) -> some View where S: OrderedBulletMarkdownStyle {
        environment(\.markdownOrderedBulletStyle, .init(style))
    }
}
