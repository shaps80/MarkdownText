import SwiftUI

public protocol CheckedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = CheckedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyCheckedListMarkdownStyle: CheckedListMarkdownStyle {
    var label: (CheckedListMarkdownConfiguration) -> AnyView
    init<S: CheckedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct CheckedListMarkdownConfiguration {
    public let items: [ChecklistItem]
}

public struct DefaultCheckedListMarkdownStyle<Checked: View, Unchecked: View>: CheckedListMarkdownStyle {
    let unchecked: Unchecked
    let checked: Checked

    struct Content: View {
        @Backport.ScaledMetric private var reservedWidth: CGFloat = 25
        @Environment(\.lineSpacing) private var spacing

        let unchecked: Unchecked
        let checked: Checked
        let items: [ChecklistItem]

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(items.indices, id: \.self) { index in
                    Backport.Label {
                        items[index].label
                    } icon: {
                        Group {
                            if items[index].isChecked {
                                checked
                            } else {
                                unchecked
                            }
                        }
                        .frame(minWidth: reservedWidth)
                    }
                }
            }
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        Content(unchecked: unchecked, checked: checked, items: configuration.items)
    }
}

public struct NoCheckedListMarkdownStyle: CheckedListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension CheckedListMarkdownStyle where Self == NoCheckedListMarkdownStyle {
    static var hidden: Self { NoCheckedListMarkdownStyle() }
}

extension Image {
    static var unchecked: Self { .init(systemName: "circle") }
    static var checked: Self { .init(systemName: "checkmark.circle.fill") }
}

public extension CheckedListMarkdownStyle where Self == DefaultCheckedListMarkdownStyle<Image, Image> {
    static var `default`: Self { .init() }

    init() {
        self.init(unchecked: .unchecked, checked: .checked)
    }
}

private struct CheckedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCheckedListMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownChecklistStyle: AnyCheckedListMarkdownStyle {
        get { self[CheckedListMarkdownEnvironmentKey.self] }
        set { self[CheckedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownChecklistStyle<S>(_ style: S) -> some View where S: CheckedListMarkdownStyle {
        environment(\.markdownChecklistStyle, AnyCheckedListMarkdownStyle(style))
    }
}
