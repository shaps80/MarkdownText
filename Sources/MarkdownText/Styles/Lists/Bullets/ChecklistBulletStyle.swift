import SwiftUI

public protocol CheckListBulletMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = CheckListBulletMarkdownConfiguration
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

public struct CheckListBulletMarkdownConfiguration {
    struct Label: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        public let isChecked: Bool

        var body: some View {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .frame(minWidth: reservedWidth)
        }
    }

    public let isChecked: Bool

    public var label: some View {
        Label(isChecked: isChecked)
    }
}

public struct DefaultChecklistBulletMarkdownStyle: CheckListBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension CheckListBulletMarkdownStyle where Self == DefaultChecklistBulletMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct ChecklistBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyCheckListBulletMarkdownStyle = .init(DefaultChecklistBulletMarkdownStyle())
}

public extension EnvironmentValues {
    var markdownCheckListBulletStyle: AnyCheckListBulletMarkdownStyle {
        get { self[ChecklistBulletMarkdownEnvironmentKey.self] }
        set { self[ChecklistBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownCheckListBulletStyle<S>(_ style: S) -> some View where S: CheckListBulletMarkdownStyle {
        environment(\.markdownCheckListBulletStyle, .init(style))
    }
}
