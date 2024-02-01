import CoreData

extension Database {
    func tags(ascendingSort: Bool = true) -> [TagEntity]? {
        let request = TagEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: ascendingSort)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Database: tags error: \(error.localizedDescription)")
        }

        return nil
    }

    func tag(id: UUID) -> TagEntity? {
        let context = container.viewContext

        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try context.fetch(request).first
        } catch {
            print("Database: tag(\(id)) error: \(error.localizedDescription)")
            return nil
        }
    }

    func tag(name: String) -> TagEntity? {
        let context = container.viewContext

        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)

        do {
            return try context.fetch(request).first
        } catch {
            print("Database: tag(\(name)) error: \(error.localizedDescription)")
            return nil
        }
    }

    @discardableResult
    func addTag(id: UUID, name: String) -> (added: Bool, entity: TagEntity?) {
        let context = container.viewContext

        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ OR name == %@", id as CVarArg, name)

        do {
            let entities = try context.fetch(request)
            guard entities.isEmpty else {
                print("Database: addTag(\(id)) error: Duplicate has found!")
                return (false, entities.first)
            }
        } catch {
            print("Database: addTag(\(id)) error: \(error.localizedDescription)")
            return (false, nil)
        }

        let entity = TagEntity(context: context)
        entity.id = id
        entity.name = name
        entity.date = Date.now

        print("Database: addTag(\(id)) success!")

        return (true, entity)
    }

    func deleteTag(entity: TagEntity) {
        container.viewContext.delete(entity)
    }

    func deleteTag(id: UUID) {
        let context = container.viewContext

        let request = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let entities = try context.fetch(request)

            guard !entities.isEmpty else {
                return
            }

            entities.forEach {
                context.delete($0)
            }

            print("Database: deleteTag(\(id)) success!")
        } catch {
            print("Database: deleteTag(\(id)) error: \(error.localizedDescription)")
        }
    }
}
