//
//  RecurrentPaymentViewController.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

final class RecurrentPaymentViewController: UIViewController, IRecurrentPaymentViewInput, PullableContainerContent {
    
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

    private let presenter: IRecurrentPaymentViewOutput
    private let keyboardService = KeyboardService()
    
    // MARK: Properties
    
    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var commonSheetView = CommonSheetView(delegate: self)
    
    // MARK: State

    private var tableViewContentSizeObservation: NSKeyValueObservation?
    private var keyboardVisible = false
    
    // MARK: Initialization

    init(presenter: IRecurrentPaymentViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "init with coder is unavailable.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsHierarchy()
        setupTableView()
        setupTableContentSizeObservation()
        setupKeyboardObserving()
        
        presenter.viewDidLoad()
    }
}

// MARK: - IRecurrentPaymentViewInput

extension RecurrentPaymentViewController {
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
    
    func closeView() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - UITableViewDataSource

extension RecurrentPaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellType(at: indexPath)

        switch cellType {
        case let .savedCard(presenter):
            let cell = tableView.dequeue(cellType: SavedCardTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .savedCardInsets
            return cell
        case let .payButton(presenter):
            let cell = tableView.dequeue(cellType: PayButtonTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .payButtonInsets
            return cell
        }
    }
}

// MARK: - PullableContainerContent Methods

extension RecurrentPaymentViewController {
    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }
}

// MARK: - CommonSheetViewDelegate

extension RecurrentPaymentViewController: CommonSheetViewDelegate {
    func commonSheetView(_ commonSheetView: CommonSheetView, didUpdateWithState state: CommonSheetState) {}

    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapPrimaryButton()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {}
}

// MARK: - Private

extension RecurrentPaymentViewController {
    private func setupViewsHierarchy() {
        view.addSubview(tableView)
        tableView.pinEdgesToSuperview()

        view.addSubview(commonSheetView)
        commonSheetView.pinEdgesToSuperview()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        tableView.alwaysBounceVertical = false
        tableView.dataSource = self

        tableView.register(SavedCardTableCell.self, PayButtonTableCell.self)
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

// MARK: - Constants

private extension UIEdgeInsets {
    static let savedCardInsets = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: 16)
    static let payButtonInsets = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
}
