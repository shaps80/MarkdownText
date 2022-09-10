import SwiftUI
import SwiftUIBackports

#if os(macOS)
typealias ScaledMetric = SwiftUI.ScaledMetric
typealias LabelStyle = SwiftUI.LabelStyle
typealias Label = SwiftUI.Label
typealias ProgressView = SwiftUI.ProgressView
#else
typealias ScaledMetric = Backport<Any>.ScaledMetric
typealias LabelStyle = SwiftUIBackports.BackportLabelStyle
typealias Label = Backport<Any>.Label
typealias ProgressView = Backport<Any>.ProgressView

extension View {
    func labelStyle<S: BackportLabelStyle>(_ style: S) -> some View {
        backport.labelStyle(style)
    }
}
#endif
