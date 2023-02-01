//
//  MainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormViewController: UIViewController, PullableContainerScrollableContent {

    // MARK: PullableContainer Properties

    var scrollView: UIScrollView { tableView }
    var pullableContainerContentHeight: CGFloat { 650 }
    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    // MARK: Dependencies

    private let presenter: IMainFormPresenter

    // MARK: Subviews

    private lazy var headerView = MainFormHeaderView(delegate: self)
    private lazy var tableView: UITableView = {
        // Явное присваивание фрейма до того, как произошел цикл autolayout,
        // позволяет избавиться от логов в консоли с конфликтами горизонтальных констрейнтов при установке `tableHeaderView`
        let tableView = UITableView(frame: view.bounds)
        tableView.separatorStyle = .none
        tableView.register(ContainerTableViewCell.self)
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        return tableView
    }()

    private lazy var savedCardView = SavedCardView()

    // MARK: Init

    init(presenter: IMainFormPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // tableHeaderView не изменяет свой размер во время лейаута.
        // Здесь выставляется высота на основе его констрейнтов
        headerView.frame.size = headerView.systemLayoutSizeFitting(
            CGSize(width: headerView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    // MARK: Initial Configuration

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.pinEdgesToSuperview()
        tableView.tableHeaderView = headerView
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {
    func updateHeader(with viewModel: MainFormHeaderViewModel) {
        headerView.update(with: viewModel)
    }

    func set(payButtonEnabled: Bool) {
        headerView.set(payButtonEnabled: payButtonEnabled)
    }
}

// MARK: - MainFormHeaderViewDelegate

extension MainFormViewController: MainFormHeaderViewDelegate {
    func headerViewDidTapPrimaryButton() {
        presenter.viewDidTapPayButton()
    }
}

// MARK: - PullableContainerContent Methods

extension MainFormViewController {
    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }
}

extension MainFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = presenter.row(at: indexPath)

        switch row {
        case let .savedCard(savedCardPresenter):
            savedCardView.presenter = savedCardPresenter
            let cell = tableView.dequeue(cellType: ContainerTableViewCell.self, indexPath: indexPath)
            cell.setContent(savedCardView, insets: .savedCardInsets)
            return cell
        }
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let savedCardInsets = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
}
