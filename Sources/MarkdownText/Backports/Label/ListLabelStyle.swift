import SwiftUI

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, deprecated: 14)
@available(watchOS, deprecated: 7)
extension Backport where Wrapped == Any {

    /// The default label style in the current context.
    ///
    /// You can also use ``LabelStyle/automatic`` to construct this style.
    public struct ListLabelStyle: BackportLabelStyle {
        struct Content: View {
            let configuration: Configuration

            var body: some View {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    configuration.icon
                    Text(Array(repeating: " ", count: 1).joined())
                    configuration.title
                }
            }
        }

        public init() { }

        /// Creates a view that represents the body of a label.
        ///
        /// The system calls this method for each ``Label`` instance in a view
        /// hierarchy where this style is the current label style.
        ///
        /// - Parameter configuration: The properties of the label.
        public func makeBody(configuration: Configuration) -> some View {
            Content(configuration: configuration)
        }

    }

}

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, deprecated: 14)
@available(watchOS, deprecated: 7)
extension BackportLabelStyle where Self == Backport<Any>.ListLabelStyle {
    /// A label style that resolves its appearance automatically based on the
    /// current context.
    public static var list: Self { .init() }
}
