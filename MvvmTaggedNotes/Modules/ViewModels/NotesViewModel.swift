import Foundation
import Combine

class NotesViewModel {
    private(set) var notes: [[NoteModel]] = []
    private(set) var tags: [TagModel] = []

    private var modelUpdatedSubject = PassthroughSubject<([[NoteModel]], [TagModel]), Never>()
}

// MARK: - Publishers

extension NotesViewModel {
    var modelUpdated: AnyPublisher<([[NoteModel]], [TagModel]), Never> {
        modelUpdatedSubject.eraseToAnyPublisher()
    }
}

// MARK: - Operations

extension NotesViewModel {
    func fetch() {
        guard fetchNotesAndTags() else {
            return
        }
        modelUpdatedSubject.send((notes, tags))
    }

    func removeNote(indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let noteId = notes[section][row].id

        Database.shared.deleteNote(id: noteId)

        fetchNotesAndTags()
    }

    @discardableResult
    private func fetchNotesAndTags() -> Bool {
        guard let notes = NoteModel.notes(), let tags = TagModel.tags(ascendingSort: false) else {
            return false
        }

        self.notes = []
        tags.forEach { tag in
            self.notes.append(notes.filter { $0.tag == tag.id })
        }

        self.tags = tags

        return true
    }
}
