import Combine

class NoteViewModel {
    private(set) var note: NoteModel
    @Published var tag: TagModel
    private(set) var tags: [TagModel]?

    init(note: NoteModel, tag: TagModel) {
        self.note = note
        self.tag = tag
    }
}

// MARK: - Fetch

extension NoteViewModel {
    func fetch() {
        guard let tags = TagModel.tags() else {
            return
        }
        self.tags = tags
    }
}

// MARK: - Note

extension NoteViewModel {
    func applyNote() {
        let database = Database.shared

        guard let tagEntity = database.tag(id: tag.id) else {
            return
        }

        guard let noteEntity = database.addNote(id: note.id, text: note.text, tag: tagEntity) else {
            return
        }

        noteEntity.text = note.text
        tagEntity.addToNotes(noteEntity)
    }

    func updateNote(text: String) {
        note = NoteModel(id: note.id, text: text, tag: note.tag)
    }
}
