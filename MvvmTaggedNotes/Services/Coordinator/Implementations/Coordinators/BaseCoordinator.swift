import Combine

class BaseCoordinator<Output, Failure>: Coordinator where Failure: Error {
    let completionSubject = PassthroughSubject<Output, Failure>()
    var subscriptions = Set<AnyCancellable>()

    func run() { }
}

// MARK: - Publishers

extension BaseCoordinator {
    var completion: AnyPublisher<Output, Failure> {
        completionSubject.eraseToAnyPublisher()
    }
}
