import UIKit
import Combine

class TabBarController: UITabBarController, CoordinatorModule {
    private let completionSubject = PassthroughSubject<TabBarModuleCompletion, Never>()
    private var subscriptions = Set<AnyCancellable>()
}

// MARK: - Publishers

extension TabBarController {
    var completion: AnyPublisher<TabBarModuleCompletion, Never> {
        completionSubject.eraseToAnyPublisher()
    }
}

// MARK: - Life cycle

extension TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureView()
    }
}

// MARK: - Configurators

extension TabBarController {
    private func configure() {
        delegate = self
    }

    private func configureView() {
        tabBar.backgroundColor = .systemGray6
        tabBar.isTranslucent = true
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedViewController = (selectedViewController as? UINavigationController)?.visibleViewController else {
            return
        }
        if item.tag == 0 {
            completionSubject.send(.notesOpened(selectedViewController))
        } else if item.tag == 1 {
            completionSubject.send(.tagsOpened(selectedViewController))
        }
    }
}
