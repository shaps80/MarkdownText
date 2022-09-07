import SwiftUI

public protocol UnorderedBulletMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedBulletMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedBulletMarkdownStyle: UnorderedBulletMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: UnorderedBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct UnorderedBulletMarkdownConfiguration {
    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        let bulletStyle: UnorderedBulletStyle
        var body: some View {
            Text("\(bulletStyle.rawValue)")
                .frame(minWidth: reservedWidth)
        }
    }

    public var label: some View {
        Label(bulletStyle: .dash)
    }
}

public enum UnorderedBulletStyle: String {
    case dash = "–"
    case filledCircle = "●"
    case outlineCircle = "○"
    case square = "◼︎"
}

public struct DefaultUnorderedBulletMarkdownStyle: UnorderedBulletMarkdownStyle {
    let bulletStyle: UnorderedBulletStyle

    public init(bulletStyle: UnorderedBulletStyle) {
        self.bulletStyle = bulletStyle
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedBulletMarkdownStyle where Self == DefaultUnorderedBulletMarkdownStyle {
    static var dash: Self { .init(bulletStyle: .dash) }
    static var square: Self { .init(bulletStyle: .square) }
    static var circle: Self { .init(bulletStyle: .filledCircle) }
    static func circle(filled: Bool) -> Self { .init(bulletStyle: filled ? .filledCircle : .outlineCircle) }
}

private struct UnorderedBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyUnorderedBulletMarkdownStyle = .init(.dash)
}

public extension EnvironmentValues {
    var markdownUnorderedBulletStyle: AnyUnorderedBulletMarkdownStyle {
        get { self[UnorderedBulletMarkdownEnvironmentKey.self] }
        set { self[UnorderedBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedBulletStyle<S>(_ style: S) -> some View where S: UnorderedBulletMarkdownStyle {
        environment(\.markdownUnorderedBulletStyle, .init(style))
    }
}
