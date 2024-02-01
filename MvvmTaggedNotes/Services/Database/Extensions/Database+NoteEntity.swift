import CoreData

extension Database {
    func notes(ids: [UUID]? = nil, ascendingSort: Bool = true) -> [NoteEntity]? {
        let request = NoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: ascendingSort)]

        if let ids = ids {
            request.predicate = NSPredicate(format: "id IN %@", ids)
        }

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Database: notes error: \(error.localizedDescription)")
        }

        return nil
    }

    @discardableResult
    func addNote(id: UUID, text: String, tag: TagEntity) -> NoteEntity? {
        let context = container.viewContext

        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let entities = try context.fetch(request)
            guard entities.isEmpty else {
                print("Database: addNote(\(id)) error: Duplicate has found!")
                return entities.first
            }
        } catch {
            print("Database: addNote(\(id)) error: \(error.localizedDescription)")
            return nil
        }

        let entity = NoteEntity(context: context)
        entity.id = id
        entity.text = text
        entity.date = Date.now

        tag.addToNotes(entity)

        print("Database: addNote(\(id)) success!")

        return entity
    }

    func deleteNote(entity: NoteEntity) {
        container.viewContext.delete(entity)
    }

    func deleteNote(id: UUID) {
        let context = container.viewContext

        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let entities = try context.fetch(request)

            guard !entities.isEmpty else {
                return
            }

            entities.forEach {
                context.delete($0)
            }

            print("Database: deleteNote(\(id)) success!")
        } catch {
            print("Database: deleteNote(\(id)) error: \(error.localizedDescription)")
        }
    }
}
