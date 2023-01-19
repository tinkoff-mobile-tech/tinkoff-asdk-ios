//
//  MainFormViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormViewController: UIViewController, PullableContainerContent {
    // MARK: PullableContainer Properties

    var pullableContainerContentHeight: CGFloat = 400
    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    // MARK: Dependencies

    private let presenter: IMainFormPresenter

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
        presenter.viewDidLoad()
    }
}

// MARK: - IMainFormViewController

extension MainFormViewController: IMainFormViewController {}

// MARK: - PullableContainerContent Methods

extension MainFormViewController {
    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }
}
