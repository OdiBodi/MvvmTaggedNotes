import Combine

protocol CoordinatorModule {
    associatedtype Output
    associatedtype Failure: Error

    var completion: AnyPublisher<Output, Failure> { get }
}
