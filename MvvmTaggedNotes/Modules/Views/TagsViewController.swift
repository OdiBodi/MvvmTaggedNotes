import UIKit
import Combine

class TagsViewController: UIViewController {
    private lazy var tableView = initializeTableView()

    private var subscriptions = Set<AnyCancellable>()

    private var viewModel: TagsViewModel?
}

// MARK: - Life cycle

extension TagsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureNavigationItem()

        addSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSubviewsContraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.fetch()
    }
}

// MARK: - Initializators

extension TagsViewController {
    func initialize(viewModel: TagsViewModel) {
        self.viewModel = viewModel

        self.viewModel?.$tags.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &subscriptions)

        configureTabBarItem()
    }
}

// MARK: - Configurators

extension TagsViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
    }

    func configureNavigationItem() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add,
                                      target: self,
                                      action: #selector(onAddBarButtonItemTapped))
        navigationItem.rightBarButtonItem = addItem
    }

    private func configureTabBarItem() {
        let image = UIImage(systemName: "tag")
        tabBarItem = UITabBarItem(title: "Tags", image: image, tag: 0)
    }
}

// MARK: - Subviews

extension TagsViewController {
    private func initializeTableView() -> UITableView {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.dataSource = self
        view.delegate = self
        view.register(TagViewCell.self, forCellReuseIdentifier: TagViewCell.id)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        view.allowsMultipleSelection = false
        view.allowsSelectionDuringEditing = false
        view.allowsMultipleSelectionDuringEditing = false
        return view
    }

    private func addSubviews() {
        view.addSubview(tableView)
    }

    private func updateSubviewsContraints() {
        tableView.snp.updateConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - Utilites

extension TagsViewController {
    func scrollToTop() {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

// MARK: - Alerts

extension TagsViewController {
    private func showAddNewTagAlert() {
        let alertController = UIAlertController(title: "Add new tag", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let okAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let tagName = alertController.textFields?.first?.text, tagName.filled() else {
                return
            }
            self?.viewModel?.addTag(name: tagName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func showEditTagAlert(tag: TagModel) {
        let alertController = UIAlertController(title: "Edit tag", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = tag.name.capitalized
        }

        let applyAction = UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let tagName = alertController.textFields?.first?.text, tagName.filled() else {
                return
            }
            self?.viewModel?.editTag(id: tag.id, name: tagName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(applyAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension TagsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagViewCell.id, for: indexPath) as! TagViewCell

        let index = indexPath.item
        guard let tag = viewModel?.tags[index] else {
            return cell
        }

        cell.initialize(name: tag.name)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let index = indexPath.item
        guard let tag = viewModel?.tags[index] else {
            return false
        }
        return tag.name == Tag.untagged.rawValue ? false : true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.removeTag(indexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - UITableViewDelegate

extension TagsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.tags.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let index = indexPath.item
        guard let tag = viewModel?.tags[index], tag.name != Tag.untagged.rawValue else {
            return
        }

        showEditTagAlert(tag: tag)
    }
}

// MARK: - Callbacks

extension TagsViewController {
    @objc private func onAddBarButtonItemTapped() {
        showAddNewTagAlert()
    }
}
