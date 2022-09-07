import Foundation

/// Represents a list markdown element
public struct MarkdownList {
    /// Represents the types of lists
    public enum ListType {
        /// An unordered list
        case unordered
        /// An ordered list
        case ordered
    }

    /// The type of list this represents
    public let type: ListType
    /// The elements contained in this list. This could be single elements, or even another nested list
    public var elements: [MarkdownListElement] = []

    internal mutating func append(ordered item: OrderedListItemMarkdownConfiguration) {
        elements.append(.ordered(item))
    }

    internal mutating func append(unordered item: UnorderedListItemMarkdownConfiguration) {
        elements.append(.unordered(item))
    }

    internal mutating func append(checklist item: CheckListItemMarkdownConfiguration) {
        elements.append(.checklist(item))
    }

    internal mutating func append(nested list: Self) {
        elements.append(.list(list))
    }
}

/// Represents a list, including any nested list elements
public enum MarkdownListElement {
    /// A nested list
    case list(MarkdownList)
    /// An ordered list
    case ordered(OrderedListItemMarkdownConfiguration)
    /// An unordered list
    case unordered(UnorderedListItemMarkdownConfiguration)
    /// A checked list
    case checklist(CheckListItemMarkdownConfiguration)
}
