import Foundation

struct TagModel: Equatable {
    let id: UUID
    let name: String
    let notes: [UUID]
}

// MARK: - Tags

extension TagModel {
    static func tags(ascendingSort: Bool = true) -> [TagModel]? {
        guard let tags = Database.shared.tags(ascendingSort: ascendingSort) else {
            return nil
        }
        return tags.map { TagModel(id: $0.id!, name: $0.name!, notes: $0.notes!.map { ($0 as! NoteEntity).id! }) }
    }
}
