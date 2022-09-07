import SwiftUI

public struct RemoteImageMarkdownStyle: ImageMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ImageMarkdownStyle where Self == RemoteImageMarkdownStyle {
    static var remote: Self { .init() }
}
