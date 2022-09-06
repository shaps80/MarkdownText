import SwiftUI

public protocol EmphasisMarkdownStyle {
    typealias Configuration = EmphasisMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Text
}

public struct EmphasisMarkdownConfiguration {
    public let label: Text
}

public struct DefaultEmphasisMarkdownStyle: EmphasisMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label.bold()
    }
}

public extension EmphasisMarkdownStyle where Self == DefaultEmphasisMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct EmphasisMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: EmphasisMarkdownStyle = DefaultEmphasisMarkdownStyle()
}

public extension EnvironmentValues {
    var markdownEmphasisStyle: EmphasisMarkdownStyle {
        get { self[EmphasisMarkdownEnvironmentKey.self] }
        set { self[EmphasisMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownEmphasisStyle<S>(_ style: S) -> some View where S: EmphasisMarkdownStyle {
        environment(\.markdownEmphasisStyle, style)
    }
}
