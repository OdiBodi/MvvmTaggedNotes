extension String {
    func filled() -> Bool {
        !self.isEmpty && !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
