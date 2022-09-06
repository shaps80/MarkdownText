import SwiftUI

public protocol CheckedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = CheckedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyCheckedListMarkdownStyle {
    var label: (CheckedListMarkdownConfiguration) -> AnyView
    init<S: CheckedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct CheckedListMarkdownConfiguration {
    public let items: [ChecklistItem]
}

public struct DefaultCheckedListMarkdownStyle: CheckedListMarkdownStyle {
    let unchecked: AnyView
    let checked: AnyView

    struct Content: View {
        @Backport.ScaledMetric(wrappedValue: 30) private var padding
        @Backport.ScaledMetric(wrappedValue: 6) private var spacing

        let unchecked: AnyView
        let checked: AnyView
        let items: [ChecklistItem]

        @ViewBuilder
        private func bullet(isChecked: Bool) -> some View {
            if isChecked {
                checked
            } else {
                unchecked
            }
        }

        var body: some View {
            AnyView(
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(items.indices, id: \.self) { index in
                        items[index].content
                            .padding(.leading, padding)
                            .background(
                                bullet(isChecked: items[index].isChecked)
                                , alignment: .init(horizontal: .leading, vertical: .firstTextBaseline))
                    }
                }
            )
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        Content(unchecked: unchecked, checked: checked, items: configuration.items)
    }
}

public struct NoCheckedListMarkdownStyle: CheckedListMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension CheckedListMarkdownStyle where Self == NoCheckedListMarkdownStyle {
    static var hidden: Self { NoCheckedListMarkdownStyle() }
}

public extension CheckedListMarkdownStyle where Self == DefaultCheckedListMarkdownStyle {
    private static var uncheckedImage: Image { Image(systemName: "circle") }
    private static var checkedImage: Image { Image(systemName: "checkmark.circle.fill") }

    static var `default`: Self {
        .init(unchecked: AnyView(uncheckedImage), checked: AnyView(checkedImage))
    }
    static func `default`<Unchecked: View, Checked: View>(unchecked: Unchecked, checked: Checked) -> Self {
        .init(unchecked: AnyView(unchecked), checked: AnyView(checked))
    }

    static func `default`<Unchecked: View>(unchecked: Unchecked) -> Self {
        .init(unchecked: AnyView(unchecked), checked: AnyView(checkedImage))
    }

    static func `default`<Checked: View>(checked: Checked) -> Self {
        .init(unchecked: AnyView(uncheckedImage), checked: AnyView(checked))
    }

    static func `default`(unchecked: Color?) -> Self {
        .init(unchecked: AnyView(uncheckedImage.foregroundColor(unchecked)), checked: AnyView(checkedImage))
    }

    static func `default`(checked: Color?) -> Self {
        .init(unchecked: AnyView(uncheckedImage), checked: AnyView(checkedImage.foregroundColor(checked)))
    }

    static func `default`(unchecked: Color?, checked: Color?) -> Self {
        .init(unchecked: AnyView(uncheckedImage.foregroundColor(unchecked)), checked: AnyView(checkedImage.foregroundColor(checked)))
    }
}

private struct CheckedListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCheckedListMarkdownStyle(.default)
}

extension EnvironmentValues {
    var checkedListMarkdownStyle: AnyCheckedListMarkdownStyle {
        get { self[CheckedListMarkdownEnvironmentKey.self] }
        set { self[CheckedListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func checkedListStyle<S>(_ style: S) -> some View where S: CheckedListMarkdownStyle {
        environment(\.checkedListMarkdownStyle, AnyCheckedListMarkdownStyle(style))
    }
}
