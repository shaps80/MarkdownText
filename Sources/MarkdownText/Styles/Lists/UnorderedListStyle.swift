import SwiftUI

public protocol UnorderedListMarkdownStyle {
    associatedtype Body: View
    typealias Configuration = UnorderedListMarkdownConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyUnorderedListMarkdownStyle: UnorderedListMarkdownStyle {
    var label: (Configuration) -> AnyView
    init<S: UnorderedListMarkdownStyle>(_ style: S) {
        label = { AnyView(style.makeBody(configuration: $0)) }
    }
    public func makeBody(configuration: Configuration) -> some View {
        label(configuration)
    }
}

public struct UnorderedListMarkdownConfiguration {
}
