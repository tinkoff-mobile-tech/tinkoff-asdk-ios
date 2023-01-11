//
//  StubViewManager.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 10.01.2023.
//

final class StubViewManager {

    // MARK: - Property list

    private weak var stubView: StubView?

    private let stubBuilder: IStubViewBuilder

    // MARK: - Initialization

    init(stubBuilder: IStubViewBuilder) {
        self.stubBuilder = stubBuilder
    }

    // MARK: - Public methods

    /// Если плейсхолдера нет, то создаст его, добавит на супервью и анимированно покажет
    /// Если плейсхолдер уже есть, то просто анимированно покажет его
    /// - Parameters:
    ///   - superview: вьюха на которую будет добавлен плейсхолдер
    ///   - mode: тип плейсходера
    func addStubView(superview: UIView, mode: StubMode) {
        if let stubView = stubView {
            UIView.animateShow(view: stubView)
            return
        }

        let stubView = stubBuilder.buildFrom(coverMode: mode)
        stubView.center = superview.center
        UIView.animateAddSubview(stubView, at: superview)

        self.stubView = stubView
    }

    /// Удаляет плейсхолдер с супервью
    func removeStubView() {
        stubView?.removeFromSuperview()
    }
}
