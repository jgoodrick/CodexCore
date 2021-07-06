//  
//  Created by Joseph Goodrick on 7/5/21
//  

import XCTest
@testable import CodexCore

class KeyPathSortTests: XCTestCase {
    func test_sort_empty_returnsEmpty() {
        let sut: [String] = []
        XCTAssertEqual(sut.sorted(by: \.self), [])
    }
    
    func test_sort_one_returnsSame() {
        let sut = ["1"]
        XCTAssertEqual(sut.sorted(by: \.self), ["1"])
    }
    
    func test_sort_many_matchesDefaultSort() {
        let item1 = "1"
        let item2 = "2"
        let item3 = "3"
        let sut = [item1, item3, item2]
            
        XCTAssertEqual(sut.sorted(by: \.self), sut.sorted())
    }
}
