
public class TextStage {
    public var text: String {
        didSet {
            if textGraph != nil {
                textGraph = nil
            }
            let text = sanitizer.sanitized(text)
            if !text.isEmpty {
                correlator.textGraph(for: text) { [weak self] output in
                    guard let self = self else { return }
                    self.textGraph = output
                }
            }
        }
    }
    
    public private(set) var textGraph: TextGraph? {
        didSet {
            onGraph(textGraph)
        }
    }
    
    private let sanitizer: TextSanitizer
    private let correlator: TextCorrelator
    private let onGraph: (TextGraph?) -> Void
    
    public init(
        text: String,
        textGraph: TextGraph?,
        sanitizer: TextSanitizer,
        correlator: TextCorrelator,
        onGraph: @escaping (TextGraph?) -> Void
    ) {
        self.text = text
        self.textGraph = textGraph
        self.sanitizer = sanitizer
        self.correlator = correlator
        self.onGraph = onGraph
    }
}
