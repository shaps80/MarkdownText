import SwiftUI
import SwiftUIBackports

struct ImageMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownImageVisibility: ImageMarkdownVisibility.Value {
        get { self[ImageMarkdownVisibility.self] }
        set { self[ImageMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    func markdownImage(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownImageVisibility, visibility)
    }
}
