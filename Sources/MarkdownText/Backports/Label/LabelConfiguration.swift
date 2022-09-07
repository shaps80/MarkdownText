import SwiftUI

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, deprecated: 14)
@available(watchOS, deprecated: 7)
extension Backport where Wrapped == Any {

    /// The properties of a label.
    struct LabelStyleConfiguration {

        /// A type-erased title view of a label.
        struct Title: View {
            let content: AnyView
            var body: some View { content }
            init<Content: View>(content: Content) {
                self.content = .init(content)
            }
        }

        /// A type-erased icon view of a label.
        struct Icon: View {
            let content: AnyView
            var body: some View { content }
            init<Content: View>(content: Content) {
                self.content = .init(content)
            }
        }

        /// A description of the labeled item.
        internal(set) var title: LabelStyleConfiguration.Title

        /// A symbolic representation of the labeled item.
        internal(set) var icon: LabelStyleConfiguration.Icon

        internal var environment: EnvironmentValues = .init()

        func environment(_ values: EnvironmentValues) -> Self {
            var config = self
            config.environment = values
            return config
        }

    }

}
