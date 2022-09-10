import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to checklist bullet markdown elements
public protocol CheckListBulletMarkdownStyle {
    associatedtype Body: View
    /// The properties of a checklist bullet markdown element
    typealias Configuration = CheckListBulletMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyCheckListBulletMarkdownStyle: CheckListBulletMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: CheckListBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a checklist bullet markdown element
public struct CheckListBulletMarkdownConfiguration {
    private struct Label: View {
        @ScaledMetric private var reservedWidth: CGFloat = 25
        public let isChecked: Bool

        var body: some View {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .frame(minWidth: reservedWidth)
        }
    }

    /// A boolean that represents whether the checklist item is selected or not
    public let isChecked: Bool
    /// Returns a default checklist bullet markdown representation
    public var label: some View {
        Label(isChecked: isChecked)
    }
}

/// The default checklist bullet style
public struct DefaultChecklistBulletMarkdownStyle: CheckListBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension CheckListBulletMarkdownStyle where Self == DefaultChecklistBulletMarkdownStyle {
    /// The default checklist bullet style
    static var `default`: Self { .init() }
}

private struct ChecklistBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyCheckListBulletMarkdownStyle = .init(DefaultChecklistBulletMarkdownStyle())
}

public extension EnvironmentValues {
    /// The current checklist bullet markdown style
    var markdownCheckListBulletStyle: AnyCheckListBulletMarkdownStyle {
        get { self[ChecklistBulletMarkdownEnvironmentKey.self] }
        set { self[ChecklistBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for checklist bullet markdown elements
    func markdownCheckListBulletStyle<S>(_ style: S) -> some View where S: CheckListBulletMarkdownStyle {
        environment(\.markdownCheckListBulletStyle, .init(style))
    }
}
