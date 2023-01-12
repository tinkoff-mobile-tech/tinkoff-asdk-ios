//
//  DispatchQueue+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.12.2022.
//

extension DispatchQueue {
    
    ///  Выполняет работу только один раз для данного target(а), учитывая временное окно. Последняя добавленная кложура, это та,
    ///  которая будет выполнена в конце.
    ///  Примечание. Безопасно вызывать только из  main треда.
    ///  Пример использования:
    /*
    DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
        self?.doTheWork()
    }
     */
    /// - Parameters:
    ///   - target: Объект, используемый в качестве отслеживаемого, в большинстве случаев self.
    ///   - delay: Время задержки
    ///   - work: работа которая должна быть выполнена
    func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
        let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
        if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
            existingWorkItem.cancel()
        }
        let workItem = DispatchWorkItem {
            DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)

            for ptr in DispatchQueue.weakTargets.allObjects {
                if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
                    work()
                    break
                }
            }
        }

        DispatchQueue.workItems[dedupeIdentifier] = workItem
        DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())

        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}

// MARK: - Private

extension DispatchQueue {

    private static var workItems = [AnyHashable: DispatchWorkItem]()

    private static var weakTargets = NSPointerArray.weakObjects()

    private static func dedupeIdentifierFor(_ object: AnyObject) -> String {
        return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
    }
}
