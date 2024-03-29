import UIKit

class TagViewCell: UITableViewCell {
    private lazy var nameLabel = initializeNameLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Static

extension TagViewCell {
    static let id = "\(TagViewCell.self)"
}

// MARK: - Life cycle

extension TagViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Initializators

extension TagViewCell {
    func initialize(name: String) {
        nameLabel.text = name.capitalized
    }
}

// MARK: - Subviews

extension TagViewCell {
    private func initializeNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .systemPink
        return label
    }

    private func addSubviews() {
        contentView.addSubview(nameLabel)
    }

    private func updateSubviewsConstraints() {
        nameLabel.snp.updateConstraints { maker in
            maker.left.right.equalToSuperview().inset(16)
            maker.top.bottom.equalToSuperview()
        }
    }
}
