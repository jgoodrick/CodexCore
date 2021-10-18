
public protocol TextCorrelator {
    func textGraph(for text: String, completion: @escaping (TextGraph) -> Void)
}
