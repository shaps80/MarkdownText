import SwiftUI

public protocol CodeMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = CodeMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyCodeMarkdownStyle: CodeMarkdownStyle {
    var label: (CodeMarkdownConfiguration) -> AnyView
    init<S: CodeMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct CodeMarkdownConfiguration {
    public let code: String
    public let language: String?

    struct Label: View {
        @Environment(\.font) private var font

        let code: String
        let language: String?

        var body: some View {
            if #available(iOS 15, *) {
                Text(code.trimmingCharacters(in: .newlines))
                    .font(
                        font?.monospaced()
                        ?? .system(.body, design: .monospaced)
                    )
            } else {
                Text(code.trimmingCharacters(in: .newlines))
                    .font(.system(.body, design: .monospaced))
            }
        }
    }

    public var label: some View {
        Label(code: code, language: language)
            .font(.callout)
            .lineSpacing(5)
            .environment(\.layoutDirection, .leftToRight)
    }
}

public struct DefaultCodeMarkdownStyle: CodeMarkdownStyle {
    var axes: Axis.Set
    var showsIndicators: Bool

    public init(_ axes: Axis.Set = .horizontal, showsIndicators: Bool = false) {
        self.axes = axes
        self.showsIndicators = showsIndicators
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            configuration.label
        }
    }
}

public extension CodeMarkdownStyle where Self == DefaultCodeMarkdownStyle {
    /// The default code style in the current context.
    static var `default`: Self {
        .init()
    }

    /// The default code style in the current context.
    /// - Parameters:
    ///   - axes: The scrollable axes of the scroll view. Defaults to `Axis/horizontal`
    ///   - showsIndicators: A value that indicates whether the scroll view displays the scrollable component of the content offset. Defaults to `false`
    static func `default`(_ axes: Axis.Set, showsIndicators: Bool = false) -> Self {
        .init(axes, showsIndicators: showsIndicators)
    }
}

private struct CodeMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCodeMarkdownStyle(.default)
}

public extension EnvironmentValues {
    var markdownCodeStyle: AnyCodeMarkdownStyle {
        get { self[CodeMarkdownEnvironmentKey.self] }
        set { self[CodeMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownCodeStyle<S>(_ style: S) -> some View where S: CodeMarkdownStyle {
        environment(\.markdownCodeStyle, AnyCodeMarkdownStyle(style))
    }
}
