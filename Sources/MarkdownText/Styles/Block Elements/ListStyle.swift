import SwiftUI

public protocol ListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ListStyleMarkdownConfiguration
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

public struct ListStyleMarkdownConfiguration {
    private struct Label: View {
        @Environment(\.markdownUnorderedListItemStyle) private var unordered
        @Environment(\.markdownOrderedListItemStyle) private var ordered
        @Environment(\.markdownCheckListItemStyle) private var checklist
        @Environment(\.lineSpacing) private var spacing

        let paragraphs: [ParagraphMarkdownConfiguration]

        var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(paragraphs.indices, id: \.self) { index in
                    paragraphs[index].label
                }
            }
        }
    }

    let paragraphs: [ParagraphMarkdownConfiguration]
    public var label: some View {
        Label(paragraphs: paragraphs)
    }
}

public struct DefaultListMarkdownStyle: ListMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ListMarkdownStyle where Self == DefaultListMarkdownStyle {
    static var `default`: Self { .init() }
}

private struct ListMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyListMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownListStyle: AnyListMarkdownStyle {
        get { self[ListMarkdownEnvironmentKey.self] }
        set { self[ListMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownListStyle<S>(_ style: S) -> some View where S: ListMarkdownStyle {
        environment(\.markdownListStyle, .init(style))
    }
}