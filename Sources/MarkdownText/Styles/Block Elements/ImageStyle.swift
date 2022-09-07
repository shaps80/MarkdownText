import SwiftUI

public protocol ImageMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = ImageMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyImageMarkdownStyle: ImageMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: ImageMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct ImageMarkdownConfiguration {
    public let source: String?
    public let title: String?

    private struct Label: View {
        public let source: String?
        public let title: String?

        var body: some View {
            if let source = source {
                if let url = URL(string: source), url.scheme != nil {
                    Backport.AsyncImage(url: url, transaction: .init(animation: .default)) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFit()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    public var label: some View {
        Label(source: source, title: title)
    }
}

private struct ImageMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyImageMarkdownStyle(.automatic)
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
