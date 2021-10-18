
import XCTest
import CodexCore

class TextStageTests: XCTestCase {

    func test_clearsGraphImmediatelyAfterTextIsPopulatedBeforeCorrelation() {
        let sut = makeSUT()

        sut.text = "new value"
        
        XCTAssertNil(sut.textGraph)
    }

    func test_clearsGraphImmediatelyAfterTextIsChangedBeforeCorrelation() {
        let sut = makeSUT(text: "initial value", graph: EmptyTextGraph())

        sut.text = "new value"
        
        XCTAssertNil(sut.textGraph)
    }

    func test_callsOnGraphWithNonNilGraphAfterTextIsPopulated() {
        let exp = expectation(description: "graph update")
        var outputs = [TextGraph?]()
        let sut = makeSUT { output in
            outputs.append(output)
            if outputs.count == 1 {
                exp.fulfill()
            }
        }

        sut.text = "new value"
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNotNil(sut.textGraph)
        }
    }
    
    func test_callsOnGraphWithNilGraphAfterTextIsCleared() {
        let exp = expectation(description: "graph update")
        var outputs = [TextGraph?]()
        let sut = makeSUT(text: "some initial text", graph: EmptyTextGraph()) { output in
            outputs.append(output)
            if outputs.count == 1 {
                exp.fulfill()
            }
        }

        sut.text = ""
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(sut.textGraph)
        }
    }

    func test_populatesTextGraphAfterTextIsPopulated() {
        let exp = expectation(description: "graph update")
        var outputs = [TextGraph?]()
        let sut = makeSUT { output in
            outputs.append(output)
            if outputs.count == 1 {
                exp.fulfill()
            }
        }
        
        sut.text = "new value"
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNotNil(sut.textGraph)
        }
    }

    func test_clearsTextGraphImmediatelyAfterTextIsCleared() {
        let sut = makeSUT(graph: EmptyTextGraph())
                        
        sut.text = ""
        
        XCTAssertNil(sut.textGraph)
    }

    private func makeSUT(text: String = "", graph: TextGraph = EmptyTextGraph(), onGraph: ((TextGraph?) -> Void)? = nil) -> TextStage {
        let correlator = TextCorrelatorStub(graph: graph)
        return TextStage(text: text, textGraph: graph, sanitizer: LowercaseSanitizer(), correlator: correlator, onGraph: onGraph ?? { _ in })
    }
}

private struct LowercaseSanitizer: TextSanitizer {
    func sanitized(_ text: String) -> String {
        text.lowercased()
    }
}

private struct EmptyTextGraph: TextGraph {
    var origin: String = ""
    var spelling: [SpellingCorrelation] = []
    var translations: [TranslationCorrelation] = []
    var sentences: [SentenceCorrelation] = []
}

private struct TextCorrelatorStub: TextCorrelator {
    
    let graph: TextGraph
    
    func textGraph(for text: String, completion: @escaping (TextGraph) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(graph)
        }
    }
}
