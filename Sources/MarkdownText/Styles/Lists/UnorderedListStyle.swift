import SwiftUI

public protocol UnorderedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: UnorderedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct UnorderedListMarkdownConfiguration {
    private struct Label: View {
        @Environment(\.lineSpacing) private var spacing
        let label: AnyView

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                label
            }
        }
    }

    let label: AnyView
}

public struct DefaultUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension UnorderedListMarkdownStyle where Self == DefaultUnorderedListMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct UnorderedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyUnorderedListMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownUnorderedListStyle: AnyUnorderedListMarkdownStyle {
        get { self[UnorderedListMarkdownEnvironmentKey.self] }
        set { self[UnorderedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedListStyle<S>(_ style: S) -> some View where S: UnorderedListMarkdownStyle {
        environment(\.markdownUnorderedListStyle, AnyUnorderedListMarkdownStyle(style))
    }
}
