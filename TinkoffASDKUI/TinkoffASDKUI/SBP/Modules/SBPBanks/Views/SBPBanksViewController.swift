//
//  SBPBanksViewController.swift
//  Pods-ASDKSample
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

/// Экран доступен в нескольких состояниях:
///  1) Экран открыт через  present и список банковских приложений установленных у пользователя не пустой
///    2) Экран открыт через present и список банковских приложений установленных у пользователя пуст
///    3) Экран открыт через push со списком всех банков отличных от тех что есть у пользователя
///
///    В таком случае будет следующая конфигурация экрана:
///    1) В navigationBar слева кнопка закрыть, searchBar отсутствует, показывается список банков установленных у пользователя,
///     появляется доп ячейка "Другие банки" которая push(ит) этот же экран с оставшимся списком банков
///    2) В navigationBar слева кнопка закрыть, searchBar показан, отображется полный список всех банков
///    3) В navigationBar слева кнопка назад, searchBar показан, отображется полный список всех банков за исключением тех что были на первом экране
///
///    P.S. Все это описание должно упростить работу с модулем и дать понимание зачем нужны различные методы, такие как:
///     setupNavigationWithCloseButton, setupNavigationWithBackButton, showSearchBar, hideSearchBar
final class SBPBanksViewController: UIViewController, ISBPBanksViewController, StubViewPresentable {

    // Dependencies
    private let presenter: ISBPBanksPresenter

    // Properties
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)

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
        setupSerachController()

        presenter.viewDidLoad()
    }
}

// MARK: - ISBPBanksViewController

extension SBPBanksViewController {
    func setupNavigationWithCloseButton() {
        let leftItem = UIBarButtonItem(
            title: Loc.Acquiring.SBPBanks.buttonClose,
            style: .plain,
            target: self,
            action: #selector(closeButtonAction(_:))
        )

        navigationItem.leftBarButtonItem = leftItem
    }

    func setupNavigationWithBackButton() {
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

    func showSearchBar() {
        tableView.tableHeaderView = searchController.searchBar
    }

    func hideSearchBar() {
        tableView.tableHeaderView = nil
    }

    func reloadTableView() {
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
}

// MARK: - Actions

extension SBPBanksViewController {
    @objc private func closeButtonAction(_ sender: UIBarButtonItem) {
        presenter.closeButtonPressed()
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension SBPBanksViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        presenter.prefetch(for: indexPaths.map { $0.row })
    }
}

// MARK: - UITableViewDataSource

extension SBPBanksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellPresenter = presenter.cellPresenter(for: indexPath.row)

        let bankCell = tableView.dequeue(cellType: SBPBankCellNew.self)
        bankCell.presenter = cellPresenter

        return bankCell
    }
}

// MARK: - UITableViewDelegate

extension SBPBanksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRow(at: indexPath.row)
    }
}

// MARK: - UIScrollViewDelegate

extension SBPBanksViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - UISearchResultsUpdating

extension SBPBanksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter.searchTextDidChange(to: searchController.searchBar.text ?? "")
    }
}

// MARK: - Private methods

extension SBPBanksViewController {
    private func setupView() {
        view.backgroundColor = ASDKColors.Background.elevation1.color
    }

    private func setupNavigationBar() {
        navigationItem.title = Loc.Acquiring.Sbp.screenTitle
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

        tableView.layoutIfNeeded()

        tableView.register(cellType: SBPBankCellNew.self)
        tableView.prefetchDataSource = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56

        // Когда скролишь таблицу с searchBar и упираешься в bounce таблицы, то без этой вьюхи 'backgroundView'
        // цвет под searchBar будет отличаться от основного цвета, будет дефолтным серым
        let backgroundView = UIView()
        backgroundView.backgroundColor = ASDKColors.Background.elevation1.color
        tableView.backgroundView = backgroundView
    }

    private func setupSerachController() {
        searchController.searchResultsUpdater = self

        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar

        definesPresentationContext = true

        searchController.searchBar.backgroundColor = ASDKColors.Background.elevation1.color
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = Loc.Acquiring.SBPAllBanks.searchPlaceholder
    }
}
