import SwiftUI

struct UnorderedListItemMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownUnorderedListItemVisibility: UnorderedListItemMarkdownVisibility.Value {
        get { self[UnorderedListItemMarkdownVisibility.self] }
        set { self[UnorderedListItemMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedListItem(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownUnorderedListItemVisibility, visibility)
    }
}

struct UnorderedListItemBulletMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownUnorderedListItemBulletVisibility: UnorderedListItemBulletMarkdownVisibility.Value {
        get { self[UnorderedListItemBulletMarkdownVisibility.self] }
        set { self[UnorderedListItemBulletMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    func markdownUnorderedListItemBullet(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownUnorderedListItemBulletVisibility, visibility)
    }
}
