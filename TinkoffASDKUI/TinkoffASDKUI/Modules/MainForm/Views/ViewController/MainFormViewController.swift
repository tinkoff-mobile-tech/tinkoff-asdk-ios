//
//  MainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit
import WebKit

final class MainFormViewController: UIViewController, PullableContainerContent {
    // MARK: PullableContainer Properties

    var scrollView: UIScrollView { tableView }
    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    var pullableContainerContentHeight: CGFloat {
        if commonSheetView.isHidden {
            return keyboardVisible ? UIScreen.main.bounds.height : tableView.contentSize.height
        } else {
            return commonSheetView.estimatedHeight
        }
    }

    // MARK: Dependencies

    private let presenter: IMainFormPresenter
    private let keyboardService = KeyboardService()

    // MARK: Subviews

    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var tableHeaderView = MainFormTableHeaderView(frame: .tableHeaderInitialFrame)
    private lazy var commonSheetView = CommonSheetView(delegate: self)
    private lazy var hiddenWebView = WKWebView()

    // MARK: State

    private var tableViewContentSizeObservation: NSKeyValueObservation?
    private var keyboardVisible = false

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
        setupViewsHierarchy()
        setupTableView()
        setupCommonSheetView()
        setupTableContentSizeObservation()
        setupKeyboardObserving()
        presenter.viewDidLoad()
    }

    // MARK: Initial Configuration

    private func setupViewsHierarchy() {
        view.addSubview(hiddenWebView)
        hiddenWebView.pinEdgesToSuperview()
        hiddenWebView.isHidden = true

        view.addSubview(tableView)
        tableView.pinEdgesToSuperview()

        view.addSubview(commonSheetView)
        commonSheetView.pinEdgesToSuperview()
    }

    private func setupTableView() {
        tableView.tableHeaderView = tableHeaderView
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        tableView.alwaysBounceVertical = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            MainFormOrderDetailsTableCell.self,
            SavedCardTableCell.self,
            SwitchTableCell.self,
            EmailTableCell.self,
            PayButtonTableCell.self,
            TextHeaderTableCell.self,
            AvatarTableViewCell.self
        )
    }

    private func setupCommonSheetView() {
        commonSheetView.backgroundColor = ASDKColors.Background.elevation1.color
    }

    private func setupTableContentSizeObservation() {
        tableViewContentSizeObservation = tableView.observe(\.contentSize, options: [.new, .old]) { [weak self] _, change in
            guard let self = self, change.oldValue != change.newValue else { return }
            self.pullableContainerContentHeightDidChange?(self)
        }
    }

    private func setupKeyboardObserving() {
        keyboardService.onHeightDidChangeBlock = { [weak self] keyboardHeight, _ in
            guard let self = self else { return }
            self.keyboardVisible = keyboardHeight > 0
            self.tableView.contentInset.bottom = keyboardHeight
            self.pullableContainerContentHeightDidChange?(self)
        }
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {
    func showCommonSheet(state: CommonSheetState) {
        commonSheetView.update(state: state, animated: false)
        commonSheetView.isHidden = false
        pullableContainerContentHeightDidChange?(self)
    }

    func hideCommonSheet() {
        commonSheetView.isHidden = true
        pullableContainerContentHeightDidChange?(self)
    }

    func reloadData() {
        tableView.reloadData()
    }

    func insertRows(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
    }

    func deleteRows(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
    }

    func closeView() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - CommonSheetViewDelegate

extension MainFormViewController: CommonSheetViewDelegate {
    func commonSheetView(_ commonSheetView: CommonSheetView, didUpdateWithState state: CommonSheetState) {}

    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapPrimaryButton()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {}
}

// MARK: - PullableContainerContent Methods

extension MainFormViewController {
    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }
}

// MARK: - UITableViewDataSource

extension MainFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellType(at: indexPath)

        switch cellType {
        case let .orderDetails(presenter):
            let cell = tableView.dequeue(cellType: MainFormOrderDetailsTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .orderDetailsInsets
            return cell
        case let .savedCard(presenter):
            let cell = tableView.dequeue(cellType: SavedCardTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .savedCardInsets
            return cell
        case let .getReceiptSwitch(presenter):
            let cell = tableView.dequeue(cellType: SwitchTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .getReceiptSwitchInsets
            return cell
        case let .email(presenter):
            let cell = tableView.dequeue(cellType: EmailTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .emailInsets
            return cell
        case let .payButton(presenter):
            let cell = tableView.dequeue(cellType: PayButtonTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .payButtonInsets
            return cell
        case let .otherPaymentMethodsHeader(presenter):
            let cell = tableView.dequeue(cellType: TextHeaderTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .otherPaymentMethodsHeaderInsets
            return cell
        case let .otherPaymentMethod(paymentMethod):
            let cell = tableView.dequeue(cellType: AvatarTableViewCell.self, indexPath: indexPath)
            cell.update(with: .viewModel(from: paymentMethod))
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension MainFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - PaymentControllerUIProvider

extension MainFormViewController: PaymentControllerUIProvider {
    func hiddenWebViewToCollect3DSData() -> WKWebView {
        hiddenWebView
    }

    func sourceViewControllerToPresent() -> UIViewController? {
        self
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let orderDetailsInsets = UIEdgeInsets(top: 32, left: 16, bottom: 28, right: 16)
    static let savedCardInsets = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    static let getReceiptSwitchInsets = UIEdgeInsets(top: .zero, left: 20, bottom: 12, right: 20)
    static let emailInsets = UIEdgeInsets(top: .zero, left: 16, bottom: 8, right: 16)
    static let payButtonInsets = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
    static let otherPaymentMethodsHeaderInsets = UIEdgeInsets(vertical: 12, horizontal: 16)
}

private extension CGRect {
    static let tableHeaderInitialFrame = CGRect(origin: .zero, size: CGSize(width: .zero, height: 40))
}
