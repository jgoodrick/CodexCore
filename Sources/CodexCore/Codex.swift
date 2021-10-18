//
//  Created by Joseph Goodrick on 7/5/21
//

public class Codex<T: Identifiable> {
    
    public private(set) var allItems: [T.ID: T]
    private var onEvent: ((Event<T>) -> Void)?
    private var onInsertCollision: ((T?, T) -> T)?
    
    public init(
        _ items: [T] = [],
        onEvent: ((Event<T>) -> Void)? = nil,
        onCollision: ((T?, T) -> T)? = nil
    ) {
        self.allItems = items.asDictionary
        self.onEvent = onEvent
        self.onInsertCollision = onCollision
    }
    
    public func sorted<U: Comparable>(by keyPath: KeyPath<T, U>) -> [T] {
        allItems.values.sorted(by: keyPath)
    }
    
    public func filter<U: Comparable>(_ isIncluded: (T) -> Bool, sort sortKeyPath: KeyPath<T, U>) -> [T] {
        allItems.values.filter(isIncluded).sorted(by: sortKeyPath)
    }
    
    public func insert(_ item: T, onCollision: ((T?, T) -> T)? = nil) {
        let itemToInsert = (onCollision ?? onInsertCollision)?(allItems[item.id], item) ?? item
        allItems[item.id] = itemToInsert
        onEvent?(.added(itemToInsert))
    }
    
    public func insert(batch items: [T], onCollision: ((T?, T) -> T)? = nil) {
        items.forEach({insert($0, onCollision: onCollision)})
    }

    @discardableResult
    public func remove(byID id: T.ID) -> T? {
        guard let existing = allItems[id] else {
            return nil
        }
        allItems[id] = nil
        onEvent?(.removed(existing))
        return existing
    }
    
    @discardableResult
    public func remove(batch ids: [T.ID]) -> [T.ID: T] {
        var result = [T.ID: T]()
        ids.forEach({result[$0] = remove(byID: $0)})
        return result
    }
}

public enum Event<T: Identifiable> {
    case added(T)
    case removed(T)
}

private extension Array where Element: Identifiable {
    var asDictionary: [Element.ID: Element] {
        var result = [Element.ID: Element]()
        forEach({result[$0.id] = $0})
        return result
    }
}
