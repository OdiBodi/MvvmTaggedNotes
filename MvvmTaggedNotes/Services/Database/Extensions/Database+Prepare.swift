import Foundation

extension Database {
    func prepare() {
        addTag(id: UUID(), name: Tag.untagged.rawValue)
    }
}
