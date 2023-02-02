import SwiftUI
import SwiftUIBackports

#warning("Refactor to allow for range based API as well (inspo: DynamicType API)")

struct HeadingMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownHeadingVisibility: HeadingMarkdownVisibility.Value {
        get { self[HeadingMarkdownVisibility.self] }
        set { self[HeadingMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    /// Sets the visibility for heading markdown elements
    func markdownHeading(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownHeadingVisibility, visibility)
    }
}
