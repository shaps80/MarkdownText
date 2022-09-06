import SwiftUI

public protocol ThematicBreakMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ThematicMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyThematicMarkdownStyle {
    var label: (ThematicMarkdownConfiguration) -> AnyView
    init<S: ThematicBreakMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct ThematicMarkdownConfiguration {
    public let label = Divider()
}

public struct DefaultThematicMarkdownStyle: ThematicBreakMarkdownStyle {
    var thickness: CGFloat = 1
    var color: Color?

    public func makeBody(configuration: Configuration) -> some View {
        if let color = color {
            RoundedRectangle(cornerRadius: thickness)
                .frame(height: thickness)
                .foregroundColor(color)
        } else {
            Divider()
        }
    }
}

public struct NoThematicMarkdownStyle: ThematicBreakMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension ThematicBreakMarkdownStyle where Self == DefaultThematicMarkdownStyle {
    static var `default`: Self { .init() }
    static func rounded(thickness: CGFloat = 1, color: Color = .init(.separator)) -> Self {
        .init(thickness: thickness, color: color)
    }
}

public extension ThematicBreakMarkdownStyle where Self == NoThematicMarkdownStyle {
    static var hidden: Self { .init() }
}

private struct MarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyThematicMarkdownStyle(.default)
}

extension EnvironmentValues {
    var markdownThematicBreakStyle: AnyThematicMarkdownStyle {
        get { self[MarkdownEnvironmentKey.self] }
        set { self[MarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownThematicBreakStyle<S>(_ style: S) -> some View where S: ThematicBreakMarkdownStyle {
        environment(\.markdownThematicBreakStyle, AnyThematicMarkdownStyle(style))
    }
}
