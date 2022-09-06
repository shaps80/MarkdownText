import SwiftUI

public struct Backport<Wrapped> {
    public var wrapped: Wrapped

    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }
}

public extension View {
    var backport: Backport<Self> { Backport(self) }
}
