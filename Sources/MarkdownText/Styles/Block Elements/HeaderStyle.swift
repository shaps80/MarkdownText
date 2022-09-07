import SwiftUI

public protocol HeaderMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = HeaderMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyHeaderMarkdownStyle: HeaderMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: HeaderMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct HeaderMarkdownConfiguration {
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

public struct DefaultHeaderMarkdownStyle: HeaderMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension HeaderMarkdownStyle where Self == DefaultHeaderMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct HeaderMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyHeaderMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownHeadingStyle: AnyHeaderMarkdownStyle {
        get { self[HeaderMarkdownEnvironmentKey.self] }
        set { self[HeaderMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownHeadingStyle<S>(_ style: S) -> some View where S: HeaderMarkdownStyle {
        environment(\.markdownHeadingStyle, AnyHeaderMarkdownStyle(style))
    }
}
