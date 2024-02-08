import UIKit
import Combine
import SnapKit

class NotesViewController: BaseCoordinatorModule<NotesModuleCompletion, Never> {
    private lazy var tableView = initializeTableView()

    private var subscriptions = Set<AnyCancellable>()

    private var viewModel: NotesViewModel?
}

// MARK: - Life cycle

extension NotesViewController {
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

extension NotesViewController {
    func initialize(viewModel: NotesViewModel) {
        self.viewModel = viewModel

        self.viewModel?.modelUpdated.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &subscriptions)

        configureTabBarItem()
    }
}

// MARK: - Configurators

extension NotesViewController {
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
        let image = UIImage(systemName: "note.text")
        tabBarItem = UITabBarItem(title: "Notes", image: image, tag: 0)
    }
}

// MARK: - Subviews

extension NotesViewController {
    private func initializeTableView() -> UITableView {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.dataSource = self
        view.delegate = self
        view.register(NoteViewCell.self, forCellReuseIdentifier: NoteViewCell.id)
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

extension NotesViewController {
    func scrollToTop() {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.tags.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteViewCell.id, for: indexPath) as! NoteViewCell

        let section = indexPath.section
        let row = indexPath.row

        guard let note = viewModel?.notes[section][row] else {
            return cell
        }

        cell.initialize(text: note.text)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel?.tags[section].name
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.removeNote(indexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.tags[section].notes.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = indexPath.section
        let row = indexPath.row

        guard let note = viewModel?.notes[section][row] else {
            return
        }

        guard let tag = viewModel?.tags.first(where: { $0.id == note.tag }) else {
            return
        }

        completionSubject.send(.editNote(note: note, tag: tag))
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let textLabel = (view as? UITableViewHeaderFooterView)?.textLabel else {
            return
        }
        textLabel.font = .boldSystemFont(ofSize: 14)
        textLabel.textColor = .systemPink
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel?.tags[section].notes.count ?? 0 > 0 ? tableView.sectionHeaderHeight : 0
    }
}

// MARK: - Callbacks

extension NotesViewController {
    @objc private func onAddBarButtonItemTapped() {
        guard let tag = viewModel?.tags.first(where: { $0.name == Tag.untagged.rawValue }) else {
            return
        }

        let note = NoteModel(id: UUID(), text: "", tag: tag.id)

        completionSubject.send(.addNote(note: note, tag: tag))
    }
}
