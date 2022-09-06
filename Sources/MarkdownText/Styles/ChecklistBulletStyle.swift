import SwiftUI

public protocol ChecklistBulletMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ChecklistBulletMarkdownConfiguration
    func makeBody(configuration: Configuration) -> Body
}

public struct AnyChecklistBulletMarkdownStyle: ChecklistBulletMarkdownStyle {
    var label: (ChecklistBulletMarkdownConfiguration) -> AnyView
    init<S: ChecklistBulletMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct ChecklistBulletMarkdownConfiguration {
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

public struct DefaultChecklistBulletMarkdownStyle: ChecklistBulletMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ChecklistBulletMarkdownStyle where Self == DefaultChecklistBulletMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct ChecklistBulletMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyChecklistBulletMarkdownStyle = .init(DefaultChecklistBulletMarkdownStyle())
}

public extension EnvironmentValues {
    var markdownChecklistBulletStyle: AnyChecklistBulletMarkdownStyle {
        get { self[ChecklistBulletMarkdownEnvironmentKey.self] }
        set { self[ChecklistBulletMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownChecklistBulletStyle<S>(_ style: S) -> some View where S: ChecklistBulletMarkdownStyle {
        environment(\.markdownChecklistBulletStyle, .init(style))
    }
}
