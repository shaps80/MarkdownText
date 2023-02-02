import SwiftUI
import SwiftUIBackports

/// A type that applies a custom appearance to image markdown elements
public protocol ImageMarkdownStyle {
    associatedtype Body: View
    /// The properties of an image markdown element
    typealias Configuration = ImageMarkdownConfiguration
    /// Creates a view that represents the body of a label
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of an image markdown element
public struct ImageMarkdownConfiguration {
    /// The source of the image. Generally either a URL
    public let source: String?
    /// The title of the image
    public let title: String?

    private struct Label: View {
        private var inlineStyle = InlineMarkdownStyle()

        let source: String?
        let title: String?

        init(source: String?, title: String?) {
            self.source = source
            self.title = title
        }

        var body: some View {
            if let source = source, let url = URL(string: source), url.scheme != nil {
                if source.localizedCaseInsensitiveContains("img.shields.io")
                    || source.localizedCaseInsensitiveContains(".svg")
                {
                    inlineStyle.makeBody(configuration: .init(elements: [
                        .init(content: .init(title ?? source)),
                    ]))
                } else {
                    Backport.AsyncImage(url: url) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .empty:
                            ProgressView()
                        default:
                            EmptyView()
                        }
                    }
                    .scaledToFit()
                    .animation(.default)
                }
            }
        }
    }

    /// Returns a default image markdown representation
    public var label: some View {
        Label(source: source, title: title)
    }
}

private struct ImageMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: any ImageMarkdownStyle = DefaultImageMarkdownStyle()
}

public extension EnvironmentValues {
    /// The current image markdown style
    var markdownImageStyle: any ImageMarkdownStyle {
        get { self[ImageMarkdownEnvironmentKey.self] }
        set { self[ImageMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for image markdown elements
    func markdownImageStyle(_ style: some ImageMarkdownStyle) -> some View {
        environment(\.markdownImageStyle, style)
    }
}
