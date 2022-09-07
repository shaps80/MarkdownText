import SwiftUI

public protocol InlineCodeMarkdownStyle {
    typealias Configuration = InlineCodeMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Text
}

public struct InlineCodeMarkdownConfiguration {
    public let code: String
    internal let font: Font?

    public var label: Text {
        if #available(iOS 15, *) {
            return Text(code)
                .font(font?.monospaced() ?? .system(.body, design: .monospaced))
        } else {
            return Text(code)
                .font(.system(.body, design: .monospaced))
        }
    }
}

public struct DefaultInlineCodeMarkdownStyle: InlineCodeMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension InlineCodeMarkdownStyle where Self == DefaultInlineCodeMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct InlineCodeMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: InlineCodeMarkdownStyle = DefaultInlineCodeMarkdownStyle()
}

public extension EnvironmentValues {
    var markdownInlineCodeStyle: InlineCodeMarkdownStyle {
        get { self[InlineCodeMarkdownEnvironmentKey.self] }
        set { self[InlineCodeMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownInlineCodeStyle<S>(_ style: S) -> some View where S: InlineCodeMarkdownStyle {
        environment(\.markdownInlineCodeStyle, style)
    }
}
