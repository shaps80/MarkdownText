import SwiftUI

public protocol HeaderMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = HeaderMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyHeaderStyle {
    var label: (HeaderMarkdownConfiguration) -> AnyView
    init<S: HeaderMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct HeaderMarkdownConfiguration {
    public let label: Text
    public let level: Int

    public var preferredStyle: Font.TextStyle {
        switch level {
        case 1: return .largeTitle
        case 2: return .title
        case 3:
            if #available(iOS 14.0, *) {
                return .title2
            } else {
                return .title
            }
        case 4:
            if #available(iOS 14.0, *) {
                return .title3
            } else {
                return .title
            }
        case 5: return .headline
        default: return .subheadline
        }
    }
}

public struct NoHeaderMarkdownStyle: HeaderMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension HeaderMarkdownStyle where Self == NoHeaderMarkdownStyle {
    static var hidden: Self { NoHeaderMarkdownStyle() }
}

public struct DefaultHeaderMarkdownStyle: HeaderMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(configuration.preferredStyle))
    }
}

public extension HeaderMarkdownStyle where Self == DefaultHeaderMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct HeaderMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyHeaderStyle(.default)
}

extension EnvironmentValues {
    var headerMarkdownStyle: AnyHeaderStyle {
        get { self[HeaderMarkdownEnvironmentKey.self] }
        set { self[HeaderMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func headerStyle<S>(_ style: S) -> some View where S: HeaderMarkdownStyle {
        environment(\.headerMarkdownStyle, AnyHeaderStyle(style))
    }
}
