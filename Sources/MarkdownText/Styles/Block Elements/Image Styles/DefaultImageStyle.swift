import SwiftUI

/// An image style that loads content asynchronously if a valid URL is supplied, otherwise tries to load an SFSymbol
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
    /// A default image style that loads content asynchronously if a valid URL is supplied, otherwise tries to load an SFSymbol
    ///
    /// The following example will load the `star` SF Symbol
    ///
    ///     ![][star]
    ///
    /// To render a remote image:
    ///
    ///     ![Lorem Image](https://picsum.photos/500)
    ///
    static var automatic: Self { .init() }
}
