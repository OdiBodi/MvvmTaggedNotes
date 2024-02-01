import Combine

protocol Coordinator {
    associatedtype Output
    associatedtype Failure: Error

    var completion: AnyPublisher<Output, Failure> { get }

    func run()
}
