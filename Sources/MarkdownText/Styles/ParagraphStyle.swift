import SwiftUI

public protocol ParagraphMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ParagraphMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyParagraphMarkdownStyle {
    var label: (ParagraphMarkdownConfiguration) -> AnyView
    init<S: ParagraphMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct ParagraphMarkdownConfiguration {
    public let label: Text
}

public struct NoParagraphMarkdownStyle: ParagraphMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension ParagraphMarkdownStyle where Self == NoParagraphMarkdownStyle {
    static var hidden: Self { NoParagraphMarkdownStyle() }
}

public struct DefaultParagraphMarkdownStyle: ParagraphMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ParagraphMarkdownStyle where Self == DefaultParagraphMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct ParagraphMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyParagraphMarkdownStyle(.default)
}

extension EnvironmentValues {
    var paragraphMarkdownStyle: AnyParagraphMarkdownStyle {
        get { self[ParagraphMarkdownEnvironmentKey.self] }
        set { self[ParagraphMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func paragraphStyle<S>(_ style: S) -> some View where S: ParagraphMarkdownStyle {
        environment(\.paragraphMarkdownStyle, AnyParagraphMarkdownStyle(style))
    }
}
