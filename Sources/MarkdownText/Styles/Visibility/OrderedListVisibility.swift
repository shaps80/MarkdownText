import SwiftUI
import SwiftUIBackports

struct OrderedListItemMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownOrderedListItemVisibility: OrderedListItemMarkdownVisibility.Value {
        get { self[OrderedListItemMarkdownVisibility.self] }
        set { self[OrderedListItemMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    /// Sets the visibility for ordered list markdown elements
    func markdownOrderedListItem(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownOrderedListItemVisibility, visibility)
    }
}

struct OrderedListItemBulletMarkdownVisibility: EnvironmentKey {
    static let defaultValue: Backport<Any>.Visibility = .automatic
}

internal extension EnvironmentValues {
    var markdownOrderedListItemBulletVisibility: OrderedListItemBulletMarkdownVisibility.Value {
        get { self[OrderedListItemBulletMarkdownVisibility.self] }
        set { self[OrderedListItemBulletMarkdownVisibility.self] = newValue }
    }
}

public extension View {
    /// Sets the visibility for ordered bullet markdown elements
    func markdownOrderedListItemBullet(_ visibility: Backport<Any>.Visibility) -> some View {
        environment(\.markdownOrderedListItemBulletVisibility, visibility)
    }
}
