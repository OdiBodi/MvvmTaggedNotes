import UIKit

class NoteViewCell: UITableViewCell {
    private lazy var descriptionLabel = initializeDescriptionLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Static

extension NoteViewCell {
    static let id = "\(NoteViewCell.self)"
}

// MARK: - Life cycle

extension NoteViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Initializators

extension NoteViewCell {
    func initialize(text: String) {
        descriptionLabel.text = text
    }
}

// MARK: - Subviews

extension NoteViewCell {
    private func initializeDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .systemGray
        return label
    }

    private func addSubviews() {
        contentView.addSubview(descriptionLabel)
    }

    private func updateSubviewsConstraints() {
        descriptionLabel.snp.updateConstraints { maker in
            maker.left.right.equalToSuperview().inset(16)
            maker.top.bottom.equalToSuperview()
        }
    }
}
