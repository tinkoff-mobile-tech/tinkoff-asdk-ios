//
//  SBPBanksViewController.swift
//  Pods-ASDKSample
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

final class SBPBanksViewController: UIViewController, ISBPBanksViewController {

    // Dependencies
    private let presenter: ISBPBanksPresenter

    // Properties
    private let tableView = UITableView()

    // MARK: - Initialization

    init(presenter: ISBPBanksPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "init with coder is unavailable.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()

        presenter.viewDidLoad()
    }
}

// MARK: - ISBPBanksViewController

extension SBPBanksViewController {
    func reloadTableView() {
        tableView.reloadData()
    }
}

// MARK: - Actions

extension SBPBanksViewController {

    @objc private func closeButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SBPBanksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = presenter.viewModel(for: indexPath.row)

        let bankCell = tableView.dequeue(cellType: SBPBankCellNew.self)
        bankCell.set(viewModel: viewModel)

        return bankCell
    }
}

// MARK: - UITableViewDelegate

extension SBPBanksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Private methods

extension SBPBanksViewController {
    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        let leftItem = UIBarButtonItem(
            title: Loc.TinkoffAcquiring.Button.close,
            style: .plain,
            target: self,
            action: #selector(closeButtonAction(_:))
        )
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.title = Loc.Sbp.BanksList.Header.title
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.register(cellType: SBPBankCellNew.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}
