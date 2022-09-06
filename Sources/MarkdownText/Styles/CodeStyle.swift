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
    var isScrollable: Bool
    public func makeBody(configuration: Configuration) -> some View {
        if isScrollable {
            ScrollView(.horizontal, showsIndicators: false) {
                if #available(iOS 15.0, *) {
                    configuration.label
                        .font(.body.monospaced())
                } else {
                    configuration.label
                }
            }
        } else {
            if #available(iOS 15.0, *) {
                configuration.label
                    .font(.body.monospaced())
            } else {
                configuration.label
            }
        }
    }
}

public extension CodeMarkdownStyle where Self == DefaultCodeMarkdownStyle {
    static var `default`: Self { .init(isScrollable: false) }
}

private struct CodeMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyCodeMarkdownStyle(.default)
}

extension EnvironmentValues {
    var codeMarkdownStyle: AnyCodeMarkdownStyle {
        get { self[CodeMarkdownEnvironmentKey.self] }
        set { self[CodeMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func codeStyle<S>(_ style: S) -> some View where S: CodeMarkdownStyle {
        environment(\.codeMarkdownStyle, AnyCodeMarkdownStyle(style))
    }
}
