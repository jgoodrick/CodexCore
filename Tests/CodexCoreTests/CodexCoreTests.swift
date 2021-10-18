import XCTest
import CodexCore

class CodexTests: XCTestCase {

    func test_init_isEmpty() {
        XCTAssert(Codex<String>().allItems.isEmpty)
    }
    
    func test_init_withOneItem_containsOnlyThatItem() {
        XCTAssertEqual(Codex(["1"]).allItems, ["1": "1"])
    }
        
    func test_sortedItems_matchesDefaultSort() {
        let exampleKeyPath: KeyPath<String, String.ID> = \.id
        let items = ["1", "2", "3"]
        let sut = Codex(items)
        let expectedValue = items.sorted(
            by: { $0[keyPath: exampleKeyPath] < $1[keyPath: exampleKeyPath] }
        )
        XCTAssertEqual(sut.sorted(by: exampleKeyPath), expectedValue)
        XCTAssertEqual(sut.allItems.count, 3)
    }
    
    func test_filteredItems_matchesDefaultFilter() {
        let initialValues = ["1", "2", "3"]
        let sut = Codex(initialValues)
        let expectedValue = initialValues
            .sorted()
            .filter({ $0 != "" })
        XCTAssertEqual(sut.filter({ $0 != "" }, sort: \.self), expectedValue)
        XCTAssertEqual(sut.allItems.count, 3)
    }
    
    func test_insert_whenEmpty_containsOnlyThatItem() {
        let sut = Codex<String>()
        sut.insert("1")
        XCTAssertEqual(sut.allItems, ["1": "1"])
    }
    
    func test_insert_whenPopulated_includesNewItem() {
        let sut = Codex(["2", "3"])
        sut.insert("1")
        XCTAssertEqual(sut.allItems, ["1": "1", "2": "2", "3": "3"])
    }
    
    func test_insert_whenMatchingIDExists_overwritesByDefault() {
        let sut = Codex([Identified(id: "1", value: "0")])
        sut.insert(Identified(id: "1", value: "1"))
        XCTAssertEqual(sut.allItems.values.first?.value, "1")
        XCTAssertEqual(sut.allItems.count, 1)
    }
    
    func test_insert_idMatchFound_obeysDelegateByDefault() {
        let sut = Codex([Identified(id: "1", value: "0")], onCollision: { existing, new in
            existing ?? new
        })
        sut.insert(Identified(id: "1", value: "1"))
        XCTAssertEqual(sut.allItems.values.first?.value, "0")
        XCTAssertEqual(sut.allItems.count, 1)
    }
    
    func test_insert_idMatchFound_methodPassesReducer_overridesStoredReducer() {
        let sut = Codex([Identified(id: "1", value: "0")], onCollision: { existing, new in
            existing ?? new
        })
        sut.insert(Identified(id: "1", value: "1"), onCollision: { existing, new in
            new
        })
        XCTAssertEqual(sut.allItems.values.first?.value, "1")
        XCTAssertEqual(sut.allItems.count, 1)
    }
    
    func test_batchInsert_defaultReducer_overwritesOnCollision() {
        let sut = Codex([Identified(id: "1", value: "0")])
        sut.insert(batch: [Identified(id: "1", value: "1")])
        XCTAssertEqual(sut.allItems.values.first?.value, "1")
        XCTAssertEqual(sut.allItems.count, 1)
    }

    func test_batchInsert_idMatchesFound_obeysStoredReducerByDefault() {
        let sut = Codex([Identified(id: "1", value: "0")], onCollision: { existing, new in
            existing ?? new
        })
        sut.insert(Identified(id: "1", value: "1"))
        XCTAssertEqual(sut.allItems.values.first?.value, "0")
        XCTAssertEqual(sut.allItems.count, 1)
    }

    func test_batchInsert_idMatchesFound_methodPassesReducer_overridesStoredReducer() {
        let sut = Codex([Identified(id: "1", value: "0")], onCollision: { existing, new in
            existing ?? new
        })
        sut.insert(batch: [Identified(id: "1", value: "1")], onCollision: { existing, new in
            new
        })
        XCTAssertEqual(sut.allItems.values.first?.value, "1")
        XCTAssertEqual(sut.allItems.count, 1)
    }

    func test_insert_multipleCallsWithSameValue_sameAsSingleCall() {
        let sut = Codex(["1", "2", "3"])
        let sut2 = Codex(["1", "2", "3"])
                
        sut.insert("4")
        sut.insert("4")
        sut.insert("4")
        
        sut2.insert("4")
        
        XCTAssertEqual(sut.allItems, sut2.allItems)
    }
    
    func test_insertBatch_emptyBatch_doesNotChangeItems() {
        let sut = Codex(["1", "2", "3"])
        let beforeInsert = sut.allItems
        sut.insert(batch: [])
        XCTAssertEqual(sut.allItems, beforeInsert)
    }
    
    func test_insertBatch_multipleItems_sameAsInsertCalledMultipleTimes() {
        let sut = Codex(["1", "2", "3"])
        let sut2 = Codex(["1", "2", "3"])
        
        sut.insert("4")
        sut.insert("5")
        sut.insert("5")
        sut2.insert(batch: ["4", "5", "5"])
        
        XCTAssertEqual(sut.allItems, sut2.allItems)
    }
    
    func test_remove_whenEmpty_returnsNil() {
        let sut = Codex<String>()
        XCTAssertNil(sut.remove(byID: "1"))
        XCTAssertEqual(sut.allItems.count, 0)
    }
    
    func test_remove_onlyEntry_returnsEntry() {
        let sut = Codex([Identified(id: "some id", value: "some value")])
        XCTAssertEqual(sut.remove(byID: "some id")?.value, "some value")
        XCTAssertEqual(sut.allItems.count, 0)
    }
    
    func test_remove_oneAmongManyEntries_returnsSelected() {
        let sut = Codex(["1", "2", "3", "4", "5"])
        XCTAssertEqual(sut.remove(byID: "4"), "4")
        XCTAssertEqual(sut.allItems.count, 4)
    }
    
    func test_remove_idNotFound_returnsNil() {
        let sut = Codex(["1", "2", "3", "4", "5"])
        XCTAssertNil(sut.remove(byID: "6"))
        XCTAssertEqual(sut.allItems.count, 5)
    }
    
    func test_removeBatch_whenDisjoint_returnsEmpty() {
        let sut = Codex(["1", "2", "3"])
        XCTAssert(sut.remove(batch: ["4", "5", "6"]).isEmpty)
    }
    
    func test_removeBatch_onIntersection_removesAndReturnsValues() {
        let sut = Codex(["1", "2", "3"])
        XCTAssertEqual(sut.remove(batch: ["2", "3", "4"]), ["2": "2", "3": "3"])
        XCTAssertEqual(sut.allItems, ["1": "1"])
    }
    
    func test_onInsertBatch_publishesAddedEvents() {
        var added: [String] = []
        var publishedEvents = 0
        let sut = Codex<String>(onEvent: { event in
            if case let .added(eventValue) = event {
                added.append(eventValue)
                publishedEvents += 1
            }
        })
        XCTAssertEqual(added, [])
        sut.insert(batch: ["1", "2", "3"])
        XCTAssertEqual(added, ["1", "2", "3"])
        XCTAssertEqual(publishedEvents, 3)
    }
    
    func test_onRemoveBatch_publishesRemoveEvents() {
        var removed: [String] = []
        var publishedEvents = 0
        let sut = Codex<String>(["1", "2", "3", "4", "5"], onEvent: { event in
            if case let .removed(eventValue) = event {
                removed.append(eventValue)
                publishedEvents += 1
            }
        })
        XCTAssertEqual(removed, [])
        sut.remove(batch: ["1", "2", "3"])
        XCTAssertEqual(removed, ["1", "2", "3"])
        XCTAssertEqual(sut.allItems, ["4": "4", "5": "5"])
        XCTAssertEqual(publishedEvents, 3)
    }

    func test_onInsertBatch_publishesAddedEvents_overridesDefaultReducer() {
        var added: [String] = []
        var publishedEvents = 0
        let sut = Codex<String>(onCollision: { _, _ in
            XCTFail("Not overridden")
            return ""
        })
        sut.insert(batch: ["1", "2", "3"]) { (existing, inserted) in
            added.append(inserted)
            publishedEvents += 1
            return inserted
        }
        XCTAssertEqual(added, ["1", "2", "3"])
        XCTAssertEqual(publishedEvents, 3)
    }
    
}

extension String: Identifiable {
    public var id: String { self }
}

private struct Identified: Identifiable {
    var id: String
    var value: String
}

