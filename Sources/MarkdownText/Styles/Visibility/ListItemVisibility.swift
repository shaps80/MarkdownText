import SwiftUI
import SwiftUIBackports

struct ListMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownListVisibility: ListMarkdownVisibility.Value {
        get { self[ListMarkdownVisibility.self] }
        set { self[ListMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    /// Sets the visibility for all list item markdown elements
    func markdownList(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownListVisibility, visibility)
    }
}
