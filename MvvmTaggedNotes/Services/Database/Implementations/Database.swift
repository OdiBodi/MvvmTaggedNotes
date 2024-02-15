import CoreData

class Database {
    lazy var container: NSPersistentContainer = initializeContainer()
}

// MARK: - Static

extension Database {
    static let shared = Database()
}

// MARK: - Initializators

extension Database {
    private func initializeContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "TaggedNotes")

        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Database: loadPersistentStores error: \(error.localizedDescription)")
            } else {
                print("Database: loadPersistentStores success!")
            }
        }

        return container
    }
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
            print("Database: save error: \(error.localizedDescription)")
        }

        print("Database: save success!")
    }
}
