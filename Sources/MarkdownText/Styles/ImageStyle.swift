import SwiftUI

public protocol ImageMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ImageMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyImageMarkdownStyle: ImageMarkdownStyle {
    var label: (ImageMarkdownConfiguration) -> AnyView
    init<S: ImageMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct ImageMarkdownConfiguration {
    public let source: String?
    public let title: String
}

public struct LocalImageMarkdownStyle: ImageMarkdownStyle {
    enum Source {
        case system
        case asset
    }

    var source: Source
    var color: Color?

    public func makeBody(configuration: Configuration) -> some View {
        if let source = configuration.source {
            if let url = URL(string: source) {
                if #available(iOS 15.0, *) {
                    AsyncImage(url: url)
                } else {
                    Text("[\(configuration.title)]")
                }
            } else {
                switch self.source {
                case .system:
                    Image(systemName: source)
                        .foregroundColor(color)
                case .asset:
                    Image(source)
                        .foregroundColor(color)
                }
            }
        }
    }
}

public extension ImageMarkdownStyle where Self == LocalImageMarkdownStyle {
    static var system: Self { LocalImageMarkdownStyle(source: .system) }
    static var assets: Self { LocalImageMarkdownStyle(source: .asset) }

    static func system(color: Color? = nil) -> Self { LocalImageMarkdownStyle(source: .system, color: color) }
    static func assets(color: Color? = nil) -> Self { LocalImageMarkdownStyle(source: .asset, color: color) }
}

private struct ImageMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyImageMarkdownStyle(.system)
}

public extension EnvironmentValues {
    var markdownImageStyle: AnyImageMarkdownStyle {
        get { self[ImageMarkdownEnvironmentKey.self] }
        set { self[ImageMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func markdownImageStyle<S>(_ style: S) -> some View where S: ImageMarkdownStyle {
        environment(\.markdownImageStyle, AnyImageMarkdownStyle(style))
    }
}
