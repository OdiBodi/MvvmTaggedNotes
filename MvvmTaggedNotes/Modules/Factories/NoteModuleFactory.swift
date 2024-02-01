struct NoteModuleFactory {
    func module(note: NoteModel, tag: TagModel) -> NoteViewController {
        let view = NoteViewController()
        let viewModel = NoteViewModel(note: note, tag: tag)

        view.initialize(viewModel: viewModel)

        return view
    }
}
