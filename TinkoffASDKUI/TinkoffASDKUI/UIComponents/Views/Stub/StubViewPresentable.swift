//
//  StubViewPresentable.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 10.01.2023.
//

import UIKit

private var kStubViewManagerAssociatedKey = "kStubViewManagerAssociatedKey"

/// Протокол, подписавшись на который добавляет возможность показывать и скрывать различные экраны заглушки (StubView)
/// Если подписваем UIViewController то вьюха по дефолту на которую будет вешаться StubView это view у вью контроллера
/// Если требуется добавить на другую вьюху вью контроллера, надо определить свойство stubViewPinTo
protocol StubViewPresentable {
    /// Менеджер, для управления  созданием, жизнью и удалению StubView
    var stubViewManager: StubViewManager { get }

    // Вьюха на которую будет добавлено StubView как subview
    var stubViewPinTo: UIView { get }

    func showStubView(mode: StubMode)
    func hideStubView()
}

extension StubViewPresentable {
    var stubViewManager: StubViewManager {
        if let manager = objc_getAssociatedObject(self, &kStubViewManagerAssociatedKey) as? StubViewManager {
            return manager
        }

        let stubBuilder = BaseStubViewBuilder()
        let manager = StubViewManager(stubBuilder: stubBuilder)
        objc_setAssociatedObject(self, &kStubViewManagerAssociatedKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return manager
    }

    func showStubView(mode: StubMode) {
        stubViewManager.addStubView(superview: stubViewPinTo, mode: mode)
    }

    func hideStubView() {
        stubViewManager.removeStubView()
    }
}

extension StubViewPresentable where Self: UIViewController {
    var stubViewPinTo: UIView { view }
}
