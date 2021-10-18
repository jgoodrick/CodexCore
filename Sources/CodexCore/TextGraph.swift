
public protocol TextGraph {
    var origin: String { get }
    var spelling: [SpellingCorrelation] { get }
    var translations: [TranslationCorrelation] { get }
    var sentences: [SentenceCorrelation] { get }
}

public protocol SpellingCorrelation { }
public protocol TranslationCorrelation { }
public protocol SentenceCorrelation { }

