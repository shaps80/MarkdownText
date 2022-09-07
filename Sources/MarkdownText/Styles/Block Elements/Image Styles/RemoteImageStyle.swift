import SwiftUI

/// An image style that loads content asynchronously if a valid URL is supplied
public struct RemoteImageMarkdownStyle: ImageMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ImageMarkdownStyle where Self == RemoteImageMarkdownStyle {
    /// An image style that loads content asynchronously if a valid URL is supplied
    ///
    /// Example:
    ///
    ///     ![Lorem Image](https://picsum.photos/500)
    ///     
    static var remote: Self { .init() }
}
