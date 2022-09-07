import SwiftUI

public protocol InlineLinkMarkdownStyle {
    typealias Configuration = InlineLinkMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Text
}

public struct InlineLinkMarkdownConfiguration {
    public let content: Text
    public var label: Text { content }
}

public struct DefaultInlineLinkMarkdownStyle: InlineLinkMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension InlineLinkMarkdownStyle where Self == DefaultInlineLinkMarkdownStyle {
    static var nonInteractiveInline: Self { .init() }
}

private struct InlineLinkMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: InlineLinkMarkdownStyle = DefaultInlineLinkMarkdownStyle.nonInteractiveInline
}

public extension EnvironmentValues {
    var markdownInlineLinkStyle: InlineLinkMarkdownStyle {
        get { self[InlineLinkMarkdownEnvironmentKey.self] }
        set { self[InlineLinkMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownInlineLinkStyle<S>(_ style: S) -> some View where S: InlineLinkMarkdownStyle {
        environment(\.markdownInlineLinkStyle, style)
    }
}
