//  
//  Created by Joseph Goodrick on 7/5/21
//  

import Foundation

internal extension Collection {
    func sorted<U: Comparable>(by keyPath: KeyPath<Element, U>) -> [Element] {
        sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath]} )
    }

    /// This works, but doesn't actually save any code. It is debatable if this is worth using
//    func filter<T: Comparable>(_ keyPath: KeyPath<Element, T>, _ comparator: (T, T) -> Bool, _ value: T) -> [Element] {
//        filter({comparator($0[keyPath: keyPath], value)})
//    }
}
