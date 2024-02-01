import CoreData

class Database {
    static let shared = Database()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaggedNotes")

        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Database: container.loadPersistentStores error: \(error.localizedDescription)")
            } else {
                print("Database: container.loadPersistentStores success!")
            }
        }

        return container
    }()
}

// MARK: - Operations

extension Database {
    func save() {
        let context = container.viewContext

        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
        } catch {
            print("Database: context.save error: \(error.localizedDescription)")
        }

        print("Database: save success!")
    }
}
