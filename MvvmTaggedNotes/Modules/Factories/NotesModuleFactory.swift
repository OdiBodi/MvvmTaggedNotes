struct NotesModuleFactory {
    func module() -> NotesViewController {
        let view = NotesViewController()
        let viewModel = NotesViewModel()

        view.initialize(viewModel: viewModel)

        return view
    }
}
