import UIKit
import Combine

class BaseCoordinatorModule<Output, Failure>: UIViewController, CoordinatorModule where Failure: Error {
    let completionSubject = PassthroughSubject<Output, Failure>()
}

// MARK: - Publishers

extension BaseCoordinatorModule {
    var completion: AnyPublisher<Output, Failure> {
        completionSubject.eraseToAnyPublisher()
    }
}
