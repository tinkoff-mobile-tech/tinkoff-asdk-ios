import SwiftyJSON
import TinkoffMockStrapping

public class GetCardListStub: NetworkStub {}

public extension GetCardListStub {
    func addCard(_ newCard: JSON) {
        json.arrayObject?.append(newCard)
    }
}

public class GetCardListStubs {

    private lazy var url = "v2/GetCardList"
    private lazy var defaultJson = JSON([
        ["CardId": "4750", "Pan": "543211******4773", "Status": "A", "RebillId": "145919"],
        ["CardId": "5100", "Pan": "411111******1111", "Status": "A", "RebillId": "145917"],
    ])

    /// Возвращает обыкновенный ответ `example`.
    lazy var `default`: GetCardListStub = .default(url: url, httpMethod: .POST, json: defaultJson)

    /// Возвращает запрос с ошибкой `internalServerError`.
    lazy var internalServerError: GetCardListStub = .error(url: url, error: .internalServerError)

    /// Возвращает запрос с ошибкой `notFoundError`.
    lazy var notFoundError: GetCardListStub = .error(url: url, error: .notFoundError)
}

public extension NetworkStub {
    static let getCardList = GetCardListStubs()
}
