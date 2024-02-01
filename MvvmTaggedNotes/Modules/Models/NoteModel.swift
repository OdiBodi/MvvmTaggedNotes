import Foundation

struct NoteModel: Equatable {
    let id: UUID
    let text: String
    let tag: UUID
}

// MARK: - Notes

extension NoteModel {
    static func notes(ascendingSort: Bool = true) -> [NoteModel]? {
        guard let notes = Database.shared.notes(ascendingSort: ascendingSort) else {
            return nil
        }
        return notes.map { NoteModel(id: $0.id!, text: $0.text!, tag: $0.tag!.id!) }
    }
}
