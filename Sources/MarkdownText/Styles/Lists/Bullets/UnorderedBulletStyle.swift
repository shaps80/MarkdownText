import SwiftUI
import SwiftUIBackports

public enum UnorderedListBulletStyle: String {
    case filledCircle = "●"
    case outlineCircle = "○"
    case square = "◼︎"
}

public protocol UnorderedListBulletMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedListBulletMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedListBulletMarkdownStyle: UnorderedListBulletMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: UnorderedListBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct UnorderedListBulletMarkdownConfiguration {
    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        let bulletStyle: UnorderedListBulletStyle
        var body: some View {
            Text("\(bulletStyle.rawValue)")
                .frame(minWidth: reservedWidth)
        }
    }

    public let level: Int
    private var bulletStyle: UnorderedListBulletStyle {
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

public struct DefaultUnorderedListBulletMarkdownStyle: UnorderedListBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedListBulletMarkdownStyle where Self == DefaultUnorderedListBulletMarkdownStyle {
    static var automatic: Self { .init() }
}

private struct UnorderedListBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyUnorderedListBulletMarkdownStyle = .init(.automatic)
}

public extension EnvironmentValues {
    var markdownUnorderedListBulletStyle: AnyUnorderedListBulletMarkdownStyle {
        get { self[UnorderedListBulletMarkdownEnvironmentKey.self] }
        set { self[UnorderedListBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedListBulletStyle<S>(_ style: S) -> some View where S: UnorderedListBulletMarkdownStyle {
        environment(\.markdownUnorderedListBulletStyle, .init(style))
    }
}
