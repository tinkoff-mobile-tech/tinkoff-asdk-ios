import SwiftyJSON
import TinkoffMockStrapping

public class AttachCardStub: NetworkStub {}

public class AttachCardStubs {

    private lazy var url = "v2/AttachCard"
    private lazy var defaultJson = JSON([
        "Success": true,
        "ErrorCode": "0",
        "TerminalKey": "1578942570730",
        "RequestKey": "1c5838e3-0e8f-4c94-8b4b-fe33771f3fca",
        "CustomerKey": "TestSDK_CustomerKey1123413431",
        "CardId": "528359748",
    ]
    )

    /// Возвращает обыкновенный ответ `example`.
    lazy var `default`: AttachCardStub = .default(url: url, httpMethod: .POST, json: defaultJson)

    /// Возвращает запрос с ошибкой `internalServerError`.
    lazy var internalServerError: AttachCardStub = .error(url: url, error: .internalServerError)

    /// Возвращает запрос с ошибкой `notFoundError`.
    lazy var notFoundError: AttachCardStub = .error(url: url, error: .notFoundError)
}

public extension NetworkStub {
    static let attachCard = AttachCardStubs()
}
