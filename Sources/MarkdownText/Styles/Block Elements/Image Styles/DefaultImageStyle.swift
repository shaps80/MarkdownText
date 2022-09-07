import SwiftUI

public struct DefaultImageMarkdownStyle: ImageMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        if let source = configuration.source, let url = URL(string: source), url.scheme != nil {
            RemoteImageMarkdownStyle()
                .makeBody(configuration: configuration)
        } else {
            SFSymbolImageMarkdownStyle()
                .makeBody(configuration: configuration)
        }
    }
}

public extension ImageMarkdownStyle where Self == DefaultImageMarkdownStyle {
    static var automatic: Self { .init() }
}
