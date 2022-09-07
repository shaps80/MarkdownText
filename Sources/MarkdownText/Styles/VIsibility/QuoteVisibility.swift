import SwiftUI
import SwiftUIBackports

struct QuoteMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownQuoteListVisibility: QuoteMarkdownVisibility.Value {
        get { self[QuoteMarkdownVisibility.self] }
        set { self[QuoteMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    func markdownQuote(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownQuoteListVisibility, visibility)
    }
}
