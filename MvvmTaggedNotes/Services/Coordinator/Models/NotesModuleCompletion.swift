import UIKit

enum NotesModuleCompletion {
    case addNote(note: NoteModel, tag: TagModel)
    case editNote(note: NoteModel, tag: TagModel)
}
