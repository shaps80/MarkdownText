import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to list markdown elements
public protocol ListMarkdownStyle {
    associatedtype Body: View
    /// The properties of a list markdown element
    typealias Configuration = ListStyleMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyListMarkdownStyle: ListMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: ListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

/// The properties of a list markdown element
public struct ListStyleMarkdownConfiguration {
    private struct Label: View {
        @Environment(\.markdownListStyle) private var list
        @Environment(\.markdownUnorderedListItemStyle) private var unordered
        @Environment(\.markdownOrderedListItemStyle) private var ordered
        @Environment(\.markdownCheckListItemStyle) private var checklist

        @Environment(\.markdownCheckListItemVisibility) private var checkListItemVisibility
        @Environment(\.markdownUnorderedListItemVisibility) private var unorderedListItemVisibility
        @Environment(\.markdownOrderedListItemVisibility) private var orderedListItemVisibility

        @Backport.ScaledMetric private var spacing: CGFloat = 8

        let markdownList: MarkdownList
        let level: Int

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(markdownList.elements.indices, id: \.self) { index in
                    switch markdownList.elements[index] {
                    case let .ordered(config):
                        if orderedListItemVisibility != .hidden {
                            ordered.makeBody(configuration: config)
                        }
                    case let .unordered(config):
                        if unorderedListItemVisibility != .hidden {
                            unordered.makeBody(configuration: config)
                        }
                    case let .checklist(config):
                        if checkListItemVisibility != .hidden {
                            checklist.makeBody(configuration: config)
                        }
                    case let .list(nested):
                        list.makeBody(configuration: .init(list: nested, level: level + 1))
                    }
                }
            }
        }
    }

    /// A model representing the elements of this list, including any nested lists
    public let list: MarkdownList
    /// The indentation level of the list
    public let level: Int

    /// Returns a default list markdown representation
    public var label: some View {
        Label(markdownList: list, level: level)
    }
}

/// The default list style
public struct DefaultListMarkdownStyle: ListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ListMarkdownStyle where Self == DefaultListMarkdownStyle {
    /// The default list style
    static var `default`: Self { .init() }
}

private struct ListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyListMarkdownStyle(.default)
}

public extension EnvironmentValues {
    /// The current list markdown style
    var markdownListStyle: AnyListMarkdownStyle {
        get { self[ListMarkdownEnvironmentKey.self] }
        set { self[ListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for list markdown elements
    func markdownListStyle<S>(_ style: S) -> some View where S: ListMarkdownStyle {
        environment(\.markdownListStyle, .init(style))
    }
}
