import SwiftUI

public enum UnorderedBulletStyle: String {
    case filledCircle = "●"
    case outlineCircle = "○"
    case square = "◼︎"
}

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

    public let level: Int
    private var bulletStyle: UnorderedBulletStyle {
        switch level {
        case 0: return .filledCircle
        case 1: return .outlineCircle
        default: return .square
        }
    }

    public var label: some View {
        Label(bulletStyle: bulletStyle)
    }
}

public struct DefaultUnorderedBulletMarkdownStyle: UnorderedBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedBulletMarkdownStyle where Self == DefaultUnorderedBulletMarkdownStyle {
    static var automatic: Self { .init() }
}

private struct UnorderedBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyUnorderedBulletMarkdownStyle = .init(.automatic)
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
