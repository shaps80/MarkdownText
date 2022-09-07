import SwiftUI

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
    func markdownList(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownListVisibility, visibility)
    }
}
