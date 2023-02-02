import SwiftUI
import SwiftUIBackports

struct CodeMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownCodeVisibility: CodeMarkdownVisibility.Value {
        get { self[CodeMarkdownVisibility.self] }
        set { self[CodeMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    /// Sets the visibility for code block markdown elements
    func markdownCode(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownCodeVisibility, visibility)
    }
}
