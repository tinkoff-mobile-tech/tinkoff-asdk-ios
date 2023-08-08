import SwiftyJSON
import TinkoffMockStrapping

public class AddCardStub: NetworkStub {}

public class AddCardStubs {

    private lazy var url = "v2/AddCard"
    private lazy var defaultJson = JSON([
        "Success": true,
        "ErrorCode": "0",
        "TerminalKey": "1578942570730",
        "CustomerKey": "TestSDK_CustomerKey1123413431",
        "PaymentURL": "d1f979c7-6a35-4dd0-9ba8-a9476f835d4f",
        "RequestKey": "1c5838e3-0e8f-4c94-8b4b-fe33771f3fca",
    ]
    )

    /// Возвращает обыкновенный ответ `example`.
    lazy var `default`: AddCardStub = .default(url: url, httpMethod: .POST, json: defaultJson)

    /// Возвращает запрос с ошибкой `internalServerError`.
    lazy var internalServerError: AddCardStub = .error(url: url, error: .internalServerError)

    /// Возвращает запрос с ошибкой `notFoundError`.
    lazy var notFoundError: AddCardStub = .error(url: url, error: .notFoundError)
}

public extension NetworkStub {
    static let addCard = AddCardStubs()
}
