import SwiftUI

public protocol HeadingMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = HeadingMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyHeadingMarkdownStyle: HeadingMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: HeadingMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct HeadingMarkdownConfiguration {
    public let level: Int
    let inline: InlineMarkdownConfiguration

    public var preferredStyle: Font.TextStyle {
        switch level {
        case 1: return .title
        case 2:
            if #available(iOS 14.0, *) {
                return .title2
            } else {
                return .title
            }
        case 3:
            if #available(iOS 14.0, *) {
                return .title3
            } else {
                return .title
            }
        case 4: return .headline
        default: return .subheadline
        }
    }

    private struct Label: View {
        public let level: Int
        let inline: InlineMarkdownConfiguration

        var body: some View {
            inline.label
        }
    }

    public var label: some View {
        Label(level: level, inline: inline)
            .font(.system(preferredStyle).weight(.bold))
    }
}

public struct DefaultHeadingMarkdownStyle: HeadingMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension HeadingMarkdownStyle where Self == DefaultHeadingMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct HeadingMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyHeadingMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownHeadingStyle: AnyHeadingMarkdownStyle {
        get { self[HeadingMarkdownEnvironmentKey.self] }
        set { self[HeadingMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownHeadingStyle<S>(_ style: S) -> some View where S: HeadingMarkdownStyle {
        environment(\.markdownHeadingStyle, AnyHeadingMarkdownStyle(style))
    }
}
