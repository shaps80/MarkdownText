import SwiftUI

public protocol CodeMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = CodeMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

internal struct AnyCodeMarkdownStyle {
    var label: (CodeMarkdownConfiguration) -> AnyView
    init<S: CodeMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
}

public struct CodeMarkdownConfiguration {
    public let label: Text
    public let code: String
    public let language: String?

    init(code: String, language: String?) {
        self.code = code
        self.language = language
        self.label = Text(code)
    }
}

public struct NoCodeMarkdownStyle: CodeMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public extension CodeMarkdownStyle where Self == NoCodeMarkdownStyle {
    static var hidden: Self { NoCodeMarkdownStyle() }
}

public struct DefaultCodeMarkdownStyle: CodeMarkdownStyle {
    var axes: Axis.Set
    var showsIndicators: Bool

    struct Content: View {
        @Environment(\.font) private var font

        var axes: Axis.Set
        var showsIndicators: Bool
        var label: Text

        var body: some View {
            ScrollView(axes, showsIndicators: showsIndicators) {
                if #available(iOS 15, *) {
                    label.font(font?.monospaced() ?? .system(.body, design: .monospaced))
                } else {
                    label.font(.system(.body, design: .monospaced))
                }
            }
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        Content(axes: axes, showsIndicators: showsIndicators, label: configuration.label)
    }
}

public extension DefaultCodeMarkdownStyle {
    init() {
        axes = .horizontal
        showsIndicators = false
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
        .init(axes: axes, showsIndicators: showsIndicators)
    }
}

private struct CodeMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCodeMarkdownStyle(.default)
}

extension EnvironmentValues {
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
