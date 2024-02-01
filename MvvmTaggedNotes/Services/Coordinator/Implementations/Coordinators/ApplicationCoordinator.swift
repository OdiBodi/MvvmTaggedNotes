import Combine
import UIKit

class ApplicationCoordinator: BaseCoordinator<Void, Never> {
    private let tabBarController: TabBarController

    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
    }

    override func run() {
        configureTabBarModule()
    }
}

// MARK: - Modules

extension ApplicationCoordinator {
    private func configureTabBarModule() {
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: notesModule()),
            UINavigationController(rootViewController: tagsModule())
        ]
        tabBarController.completion.sink { completion in
            switch completion {
            case .notesOpened(let viewController):
                (viewController as? NotesViewController)?.scrollToTop()
            case .tagsOpened(let viewController):
                (viewController as? TagsViewController)?.scrollToTop()
            }
        }.store(in: &subscriptions)
    }

    private func notesModule() -> NotesViewController {
        let view = NotesModuleFactory().module()

        view.completion.sink { [weak self, weak view] completion in
            switch completion {
            case .addNote(let note, let tag), .editNote(let note, let tag):
                guard let noteViewController = self?.noteModule(note: note, tag: tag) else {
                    return
                }
                view?.navigationController?.pushViewController(noteViewController, animated: true)
            }
        }.store(in: &subscriptions)

        return view
    }

    private func noteModule(note: NoteModel, tag: TagModel) -> NoteViewController {
        NoteModuleFactory().module(note: note, tag: tag)
    }

    private func tagsModule() -> TagsViewController {
        TagsModuleFactory().module()
    }
}
