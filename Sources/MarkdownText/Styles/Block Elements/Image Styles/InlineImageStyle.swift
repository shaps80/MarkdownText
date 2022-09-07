import SwiftUI

public struct SFSymbolImageMarkdownStyle: ImageMarkdownStyle {
    public func makeBody(configuration: Configuration) -> some View {
        if let source = configuration.source {
            Image(systemName: source)
        }
    }
}

public extension ImageMarkdownStyle where Self == SFSymbolImageMarkdownStyle {
    static var symbol: Self { .init() }
}
