import SwiftyJSON
import TinkoffMockStrapping

public class GetAddCardStateStub: NetworkStub {}

public class GetAddCardStateStubs {

    private lazy var url = "v2/GetAddCardState"
    private lazy var defaultJson = JSON([
        "Success": true,
        "ErrorCode": "0",
        "TerminalKey": "1578942570730",
        "RequestKey": "1c5838e3-0e8f-4c94-8b4b-fe33771f3fca",
        "Status": "COMPLETED",
    ]
    )

    /// Возвращает обыкновенный ответ `example`.
    lazy var `default`: GetAddCardStateStub = .default(url: url, httpMethod: .POST, json: defaultJson)

    /// Возвращает запрос с ошибкой `internalServerError`.
    lazy var internalServerError: GetAddCardStateStub = .error(url: url, error: .internalServerError)

    /// Возвращает запрос с ошибкой `notFoundError`.
    lazy var notFoundError: GetAddCardStateStub = .error(url: url, error: .notFoundError)
}

public extension NetworkStub {
    static let getAddCardState = GetAddCardStateStubs()
}
