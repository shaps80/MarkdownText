import SwiftUI

public protocol ChecklistMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ChecklistMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyChecklistMarkdownStyle: ChecklistMarkdownStyle {
    var label: (ChecklistMarkdownConfiguration) -> AnyView
    init<S: ChecklistMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct ChecklistMarkdownConfiguration {
    public let level: Int
    public let bullet: ChecklistBulletMarkdownConfiguration
    public let paragraph: ParagraphMarkdownConfiguration

    struct Label: View {
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownChecklistBulletStyle) private var bulletStyle

        public let level: Int
        public let bullet: ChecklistBulletMarkdownConfiguration
        public let paragraph: ParagraphMarkdownConfiguration

        var body: some View {
            Backport.Label {
                paragraphStyle.makeBody(configuration: paragraph)
            } icon: {
                bulletStyle.makeBody(configuration: bullet)
            }
        }
    }

    public var label: some View {
        Label(level: level, bullet: bullet, paragraph: paragraph)
    }
}

public struct DefaultChecklistMarkdownStyle: ChecklistMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ChecklistMarkdownStyle where Self == DefaultChecklistMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct CheckedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyChecklistMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownChecklistStyle: AnyChecklistMarkdownStyle {
        get { self[CheckedListMarkdownEnvironmentKey.self] }
        set { self[CheckedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownChecklistStyle<S>(_ style: S) -> some View where S: ChecklistMarkdownStyle {
        environment(\.markdownChecklistStyle, AnyChecklistMarkdownStyle(style))
    }
}
