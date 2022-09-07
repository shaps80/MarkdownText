import SwiftUI

public protocol StrongMarkdownStyle {
    typealias Configuration = StrongMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Text
}

public struct StrongMarkdownConfiguration {
    public let content: Text
    public var label: Text { content.bold() }
}

public struct DefaultStrongMarkdownStyle: StrongMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension StrongMarkdownStyle where Self == DefaultStrongMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct StrongMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: StrongMarkdownStyle = DefaultStrongMarkdownStyle()
}

public extension EnvironmentValues {
    var markdownStrongStyle: StrongMarkdownStyle {
        get { self[StrongMarkdownEnvironmentKey.self] }
        set { self[StrongMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownStrongStyle<S>(_ style: S) -> some View where S: StrongMarkdownStyle {
        environment(\.markdownStrongStyle, style)
    }
}
