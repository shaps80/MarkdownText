import SwiftUI

public protocol StrikethroughMarkdownStyle {
    typealias Configuration = StrikethroughMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Text
}

public struct StrikethroughMarkdownConfiguration {
    public let text: Text
    public var label: Text { text.strikethrough() }
}

public struct DefaultStrikethroughMarkdownStyle: StrikethroughMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension StrikethroughMarkdownStyle where Self == DefaultStrikethroughMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct StrikethroughMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: StrikethroughMarkdownStyle = DefaultStrikethroughMarkdownStyle()
}

public extension EnvironmentValues {
    var markdownStrikethroughStyle: StrikethroughMarkdownStyle {
        get { self[StrikethroughMarkdownEnvironmentKey.self] }
        set { self[StrikethroughMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownStrikethroughStyle<S>(_ style: S) -> some View where S: StrikethroughMarkdownStyle {
        environment(\.markdownStrikethroughStyle, style)
    }
}
