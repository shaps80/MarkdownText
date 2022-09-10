import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to checklist item markdown elements
public protocol CheckListItemMarkdownStyle {
    associatedtype Body: View
    /// The properties of a checklist item markdown element
    typealias Configuration = CheckListItemMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyCheckListItemMarkdownStyle: CheckListItemMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: CheckListItemMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a checklist item markdown element
public struct CheckListItemMarkdownConfiguration {
    private struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.markdownParagraphStyle) private var paragraphStyle
        @Environment(\.markdownCheckListBulletStyle) private var bulletStyle
        @Environment(\.markdownCheckListItemBulletVisibility) private var bulletVisibility

        let level: Int
        let bullet: CheckListBulletMarkdownConfiguration
        let paragraph: ParagraphMarkdownConfiguration

        private var space: String {
            Array(repeating: "    ", count: level).joined()
        }

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(space)

                Backport.Label {
                    paragraphStyle.makeBody(configuration: paragraph)
                } icon: {
                    if bulletVisibility != .hidden {
                        bulletStyle.makeBody(configuration: bullet)
                            .frame(minWidth: reservedWidth)
                    }
                }
                .backport.labelStyle(.list)
            }
        }
    }

    /// An integer value representing this element's indentation level
    public let level: Int
    /// The bullet configuration for this element
    public let bullet: CheckListBulletMarkdownConfiguration
    /// The content configuration for this element
    public let content: ParagraphMarkdownConfiguration
    /// Returns a default checklist item markdown representation
    public var label: some View {
        Label(level: level, bullet: bullet, paragraph: content)
    }
}

/// The default checklist item style
public struct DefaultCheckListItemMarkdownStyle: CheckListItemMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension CheckListItemMarkdownStyle where Self == DefaultCheckListItemMarkdownStyle {
    /// The default checklist item style
    static var `default`: Self { .init() }
}

private struct CheckListItemMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCheckListItemMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current checklist item markdown style
    var markdownCheckListItemStyle: AnyCheckListItemMarkdownStyle {
        get { self[CheckListItemMarkdownEnvironmentKey.self] }
        set { self[CheckListItemMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for checklist item markdown elements
    func markdownCheckListItemStyle<S>(_ style: S) -> some View where S: CheckListItemMarkdownStyle {
        environment(\.markdownCheckListItemStyle, AnyCheckListItemMarkdownStyle(style))
    }
}
