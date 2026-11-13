import GrakerCore
import GrakerKeyboard
import GrakerPlatform
import UIKit

final class KeyboardViewController: UIInputViewController {
    private var runningTask: Task<Void, Never>?
    private let statusLabel = UILabel()
    private let actionBar = UIStackView()
    private let globeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        buildLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        runningTask?.cancel()
        runningTask = nil
    }

    private func configureAppearance() {
        view.backgroundColor = .secondarySystemBackground
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 3
        statusLabel.text = "Sélectionnez du texte, puis choisissez une action."
        actionBar.axis = .horizontal
        actionBar.spacing = 8
        actionBar.distribution = .fillEqually
        globeButton.setImage(UIImage(systemName: "globe"), for: .normal)
        globeButton.addTarget(self, action: #selector(advanceToNextInputMode), for: .touchUpInside)
        globeButton.accessibilityLabel = "Changer de clavier"
    }

    private func buildLayout() {
        for mode in Mode.allCases {
            let button = UIButton(type: .system)
            button.setTitle(mode.title, for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addAction(UIAction { [weak self] _ in self?.run(mode: mode) }, for: .touchUpInside)
            actionBar.addArrangedSubview(button)
        }

        let topRow = UIStackView(arrangedSubviews: [globeButton, actionBar])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center
        globeButton.setContentHuggingPriority(.required, for: .horizontal)

        let column = UIStackView(arrangedSubviews: [statusLabel, topRow])
        column.axis = .vertical
        column.spacing = 8
        column.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(column)
        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            column.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            column.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            column.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
        ])
    }

    private func run(mode: Mode) {
        runningTask?.cancel()
        let selected = textDocumentProxy.selectedText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !selected.isEmpty else {
            statusLabel.text = KeyboardTextService.emptySelectionMessage
            return
        }
        statusLabel.text = "\(mode.title)…"
        let proxy = textDocumentProxy
        runningTask = Task { @MainActor in
            do {
                let configuration = try KeyboardTextService.loadConfiguration()
                let text = try await KeyboardTextService.process(
                    source: selected,
                    mode: mode,
                    configuration: configuration
                )
                guard !Task.isCancelled else { return }
                proxy.insertText(text)
                UIPasteboard.general.string = text
                statusLabel.text = "Inséré. Copie aussi dans le presse-papiers."
            } catch is CancellationError {
                statusLabel.text = "Annulé."
            } catch {
                statusLabel.text = error.localizedDescription
            }
        }
    }
}
