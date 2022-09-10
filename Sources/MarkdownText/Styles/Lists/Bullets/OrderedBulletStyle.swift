import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to ordered bullet markdown elements
public protocol OrderedListBulletMarkdownStyle {
    associatedtype Body: View
    /// The properties of a ordered bullet markdown element
    typealias Configuration = OrderedListBulletMarkdownConfiguration
    /// Creates a view that represents the body of a label
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

/// The properties of a ordered bullet markdown element
public struct OrderedListBulletMarkdownConfiguration {
    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        let order: Int

        var body: some View {
            Text("\(order).")
                .frame(minWidth: reservedWidth)
        }
    }

    /// An integer value representing this element's order in the list
    public let order: Int
    /// Returns a default ordered bullet markdown representation
    public var label: some View {
        Label(order: order)
    }
}

/// An ordered bullet style that presents its bullet as a numerical value (e.g. `1.`, `2.`)
public struct NumericallyOrderedListBulletMarkdownStyle: OrderedListBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension OrderedListBulletMarkdownStyle where Self == NumericallyOrderedListBulletMarkdownStyle {
    /// An ordered bullet style that presents its bullet as a numerical value (e.g. `1.`, `2.`)
    static var numerical: Self { .init() }
}

private struct OrderedBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyOrderedListBulletMarkdownStyle = .init(.numerical)
}

public extension EnvironmentValues {
    /// The current ordered bullet markdown style
    var markdownOrderedListBulletStyle: AnyOrderedListBulletMarkdownStyle {
        get { self[OrderedBulletMarkdownEnvironmentKey.self] }
        set { self[OrderedBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for ordered bullet markdown elements
    func markdownOrderedListBulletStyle<S>(_ style: S) -> some View where S: OrderedListBulletMarkdownStyle {
        environment(\.markdownOrderedListBulletStyle, .init(style))
    }
}
