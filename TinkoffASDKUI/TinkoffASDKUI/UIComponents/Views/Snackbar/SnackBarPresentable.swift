//
//  SnackBarPresentable.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 12.12.2022.
//

import UIKit

protocol ISnackBarViewProvider: AnyObject {
    func viewToAddSnackBarTo() -> UIView
}

/// In order to use Snacks conform to ISnackBarPresentable && ISnackBarViewProvider
protocol ISnackBarPresentable {
    var viewProvider: ISnackBarViewProvider? { get }

    /// Показывает 1 снек и возвращает инстантс SnackbarViewController
    /// для самостоятельной обработки (хайдинг снека контроллера)
    @discardableResult
    func showSnack(
        config: SnackbarView.Configuration,
        completion: (() -> Void)?
    ) -> SnackbarViewController

    /// Показывает 1 снек на определенное кол-во времени
    func showSnackFor(
        seconds: Double,
        config: SnackbarView.Configuration,
        didShowCompletion: (() -> Void)?,
        didHideCompletion: (() -> Void)?
    )
}

// MARK: - SnackBarPresentable Default Implementation

extension ISnackBarPresentable {

    @discardableResult
    func showSnack(
        config: SnackbarView.Configuration,
        completion: (() -> Void)?
    ) -> SnackbarViewController {
        let snackViewController = SnackbarViewController()
        assert(viewProvider != nil)
        guard let viewProvider = viewProvider else { return snackViewController }
        let viewSource = viewProvider.viewToAddSnackBarTo()
        snackViewController.view.frame = viewSource.frame
        viewSource.addSubview(snackViewController.view)
        snackViewController.viewDidLoad()
        snackViewController.viewWillAppear(true)
        snackViewController.beginAppearanceTransition(true, animated: true)
        snackViewController.showSnackView(config: config, completion: completion)
        return snackViewController
    }

    func showSnackFor(
        seconds: Double,
        config: SnackbarView.Configuration,
        didShowCompletion: (() -> Void)?,
        didHideCompletion: (() -> Void)?
    ) {
        assert(seconds > 0)
        var snackViewController: SnackbarViewController?
        DispatchQueue.main.asyncAfter(
            deadline: .now() + seconds,
            execute: {
                snackViewController?.hideSnackView(completion: didHideCompletion)
            }
        )

        snackViewController = showSnack(config: config, completion: didShowCompletion)
    }
}
