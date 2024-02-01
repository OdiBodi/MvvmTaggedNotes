struct TagsModuleFactory {
    func module() -> TagsViewController {
        let view = TagsViewController()
        let viewModel = TagsViewModel()

        view.initialize(viewModel: viewModel)

        return view
    }
}
