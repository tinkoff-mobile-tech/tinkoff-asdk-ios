//
//  MainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit
import WebKit

final class MainFormViewController: UIViewController {
    // MARK: Internal Types

    private enum Anchor: CaseIterable {
        case contentBased
        case expanded
    }

    private enum PresentationState {
        case commonSheet
        case tableView
    }

    // MARK: Dependencies

    weak var pullableContentDelegate: PullableContainerСontentDelegate?
    private let presenter: IMainFormPresenter
    private let keyboardService = KeyboardService()

    // MARK: Subviews

    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var tableHeaderView = MainFormTableHeaderView(frame: .tableHeaderInitialFrame)
    private lazy var commonSheetView = CommonSheetView(delegate: self)
    private lazy var hiddenWebView = WKWebView(frame: view.bounds)

    // MARK: State

    private let anchors = Anchor.allCases
    private var currentAnchor: Anchor = .contentBased
    private var presentationState: PresentationState = .commonSheet

    // MARK: Observations

    private var tableViewContentSizeObservation: NSKeyValueObservation?

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
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            MainFormOrderDetailsTableCell.self,
            SavedCardTableCell.self,
            SwitchTableCell.self,
            EmailTableCell.self,
            PayButtonTableCell.self,
            TextAndImageHeaderTableCell.self,
            AvatarTableViewCell.self
        )
    }

    private func setupKeyboardObserving() {
        keyboardService.onHeightDidChangeBlock = { [weak self] _, _ in
            guard let self = self, self.currentAnchor != .expanded else { return }
            self.currentAnchor = .expanded
            self.pullableContentDelegate?.updateHeight()
        }
    }

    // MARK: Table Layout Helpers

    private func height(for cellType: MainFormCellType) -> CGFloat {
        let contentHeight: CGFloat = {
            switch cellType {
            case .orderDetails:
                return .zero
            case .savedCard:
                return SavedCardView.Constants.minimalHeight
            case .getReceiptSwitch:
                return SwitchView.Constants.minimalHeight
            case .email:
                return EmailView.Constants.minimalHeight
            case .payButton:
                return PayButtonView.Constants.minimalHeight
            case .otherPaymentMethodsHeader:
                return TextHeaderView.Constants.minimalHeight
            case .otherPaymentMethod:
                return AvatarTableViewCell.Constants.minimalHeight
            }
        }()

        return contentHeight + insets(for: cellType).vertical
    }

    private func insets(for cellType: MainFormCellType) -> UIEdgeInsets {
        switch cellType {
        case .orderDetails:
            return .orderDetailsInsets
        case .savedCard:
            return .savedCardInsets
        case .getReceiptSwitch:
            return .getReceiptSwitchInsets
        case .email:
            return .emailInsets
        case .payButton:
            return .payButtonInsets
        case .otherPaymentMethodsHeader:
            return .otherPaymentMethodsHeaderInsets
        case .otherPaymentMethod:
            return .zero
        }
    }

    private func containerHeight(for cellTypes: [MainFormCellType], availableSpace: CGFloat) -> CGFloat {
        let containsDynamicElements = cellTypes.contains { $0.isEmail || $0.isGetReceiptSwitch }
        let mediumHeight = availableSpace * .mediumHeightCoefficient

        guard !containsDynamicElements else { return mediumHeight }

        let contentHeight = cellTypes.reduce(CGRect.tableHeaderInitialFrame.height) { partialResult, cellType in
            partialResult + height(for: cellType)
        }

        return min(mediumHeight, contentHeight)
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {
    func showCommonSheet(state: CommonSheetState, animatePullableContainerUpdates: Bool) {
        presentationState = .commonSheet
        currentAnchor = .contentBased

        commonSheetView.showOverlay(animated: true) {
            self.commonSheetView.set(state: state)

            self.pullableContentDelegate?.updateHeight(
                animated: animatePullableContainerUpdates,
                alongsideAnimation: { self.commonSheetView.hideOverlay(animated: !animatePullableContainerUpdates) }
            )
        }
    }

    func hideCommonSheet() {
        presentationState = .tableView
        currentAnchor = .contentBased
        tableView.setContentOffset(.zero, animated: false)

        commonSheetView.showOverlay(animated: true) {
            self.commonSheetView.set(state: .clear)

            self.pullableContentDelegate?.updateHeight(
                animated: true,
                alongsideAnimation: { self.commonSheetView.hideOverlay(animated: false) }
            )
        }
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

    func hideKeyboard() {
        view.endEditing(true)
    }

    func closeView() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - CommonSheetViewDelegate

extension MainFormViewController: CommonSheetViewDelegate {
    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapPrimaryButton()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapSecondaryButton()
    }
}

// MARK: - PullableContainerContent

extension MainFormViewController: PullableContainerContent {
    func pullableContainerDidRequestNumberOfAnchors(_ contentDelegate: PullableContainerСontentDelegate) -> Int {
        anchors.count
    }

    func pullableContainerDidRequestCurrentAnchorIndex(_ contentDelegate: PullableContainerСontentDelegate) -> Int {
        anchors.firstIndex(of: currentAnchor) ?? .zero
    }

    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didChange currentAnchorIndex: Int) {
        currentAnchor = anchors[currentAnchorIndex]
    }

    func pullabeContainer(_ contentDelegate: PullableContainerСontentDelegate, canReachAnchorAt index: Int) -> Bool {
        switch presentationState {
        case .commonSheet:
            return false
        case .tableView:
            return true
        }
    }

    func pullableContainer(
        _ contentDelegate: PullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat {
        switch (anchors[index], presentationState) {
        case (.contentBased, .tableView):
            return containerHeight(for: presenter.allCells(), availableSpace: availableSpace)
        case (.contentBased, .commonSheet):
            return commonSheetView.estimatedHeight
        case (.expanded, _):
            return availableSpace
        }
    }

    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didDragWithOffset offset: CGFloat) {
        hideKeyboard()
    }

    func pullableContainerWasClosed(_ contentDelegate: PullableContainerСontentDelegate) {
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
            cell.insets = insets(for: cellType)
            return cell
        case let .savedCard(presenter):
            let cell = tableView.dequeue(cellType: SavedCardTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        case let .getReceiptSwitch(presenter):
            let cell = tableView.dequeue(cellType: SwitchTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        case let .email(presenter):
            let cell = tableView.dequeue(cellType: EmailTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        case let .payButton(presenter):
            let cell = tableView.dequeue(cellType: PayButtonTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
            return cell
        case let .otherPaymentMethodsHeader(presenter):
            let cell = tableView.dequeue(cellType: TextAndImageHeaderTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = insets(for: cellType)
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        height(for: presenter.cellType(at: indexPath))
    }
}

// MARK: - ThreeDSWebFlowDelegate

extension MainFormViewController: ThreeDSWebFlowDelegate {
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

private extension CGFloat {
    static let mediumHeightCoefficient: CGFloat = 7 / 10
}

// MARK: IMainFormPresenter + Helpers

private extension IMainFormPresenter {
    func allCells() -> [MainFormCellType] {
        (0 ..< numberOfRows()).map { cellType(at: IndexPath(row: $0, section: .zero)) }
    }

    func containsDynamicElements() -> Bool {
        (0 ..< numberOfRows())
            .map { cellType(at: IndexPath(row: $0, section: .zero)) }
            .contains { $0.isGetReceiptSwitch || $0.isEmail }
    }
}
