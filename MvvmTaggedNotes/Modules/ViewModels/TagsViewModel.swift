import Foundation
import Combine

class TagsViewModel {
    @Published var tags: [TagModel] = []
}

// MARK: - Operations

extension TagsViewModel {
    func fetch() {
        guard let tags = TagModel.tags() else {
            return
        }
        self.tags = tags
    }

    func addTag(name: String) {
        let (added, _) = Database.shared.addTag(id: UUID(), name: name.lowercased())

        guard added else {
            return
        }

        fetch()
    }

    func removeTag(indexPath: IndexPath) {
        let database = Database.shared
        let index = indexPath.item
        let tag = tags[index]

        database.deleteTag(id: tag.id)

        if let notes = database.notes(ids: tag.notes), let untaggedTag = database.tag(name: Tag.untagged.rawValue) {
            notes.forEach { untaggedTag.addToNotes($0) }
        }

        fetch()
    }

    func editTag(id: UUID, name: String) {
        guard let tag = Database.shared.tag(id: id) else {
            return
        }

        tag.name = name

        fetch()
    }
}
