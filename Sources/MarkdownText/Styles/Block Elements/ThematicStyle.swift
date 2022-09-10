import SwiftUI

/// A type that applies a custom appearance to thematic break markdown elements
public protocol ThematicBreakMarkdownStyle {
    associatedtype Body: View
    /// The properties of a thematic break markdown element
    typealias Configuration = ThematicMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a thematic break markdown element
public struct AnyThematicMarkdownStyle: ThematicBreakMarkdownStyle {
    var label: (Configuration) -> AnyView

    init<S: ThematicBreakMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct ThematicMarkdownConfiguration {
    /// Returns a default thematic break markdown representation
    public let label = Divider()
}

/// A thematic break style represented by a SwiftUI  `Divider`
public struct DefaultThematicMarkdownStyle: ThematicBreakMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ThematicBreakMarkdownStyle where Self == DefaultThematicMarkdownStyle {
    /// A thematic break style represented by a SwiftUI  `Divider`
    static var `default`: Self { .init() }
}

private struct MarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyThematicMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current thematic break markdown style
    var markdownThematicBreakStyle: AnyThematicMarkdownStyle {
        get { self[MarkdownEnvironmentKey.self] }
        set { self[MarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for thematic break markdown elements
    func markdownThematicBreakStyle<S>(_ style: S) -> some View where S: ThematicBreakMarkdownStyle {
        environment(\.markdownThematicBreakStyle, AnyThematicMarkdownStyle(style))
    }
}
