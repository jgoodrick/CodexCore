//  
//  Created by Joseph Goodrick on 7/5/21
//  

import Foundation

internal extension Collection {
    func sorted<U: Comparable>(by keyPath: KeyPath<Element, U>) -> [Element] {
        sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath]} )
    }
}
