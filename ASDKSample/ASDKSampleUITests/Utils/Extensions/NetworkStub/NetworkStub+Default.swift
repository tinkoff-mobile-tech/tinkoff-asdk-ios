import SwiftyJSON
import TinkoffMockStrapping

public extension NetworkStub {

    /// Возвращает обычный успешный стаб.
    /// - Parameters:
    ///   - url: URL запроса.
    ///   - query: Параметры запроса.
    ///   - excludedQuery: Параметры, которых точно нет в запросе.
    ///   - jsonFileName: Содержимое ответа.
    ///   - bundle: Бандл, в котором содержится указанный файл.
    ///   - jsonModifier: Функция, модифицирующая стаб.
    /// Returns success stub
    /// - Parameters:
    ///   - url: url
    ///   - query: query-params
    ///   - excludedQuery: Query-params parameters that are definitely not in the request
    ///   - jsonFileName: Filename with response
    ///   - bundle: Bundle in which `jsonFileName` is located
    ///   - jsonModifier: Json-modifier closure
    static func `default`<Stub: NetworkStub>(
        url: String,
        query: [String: String] = [:],
        excludedQuery: [String: String?] = [:],
        httpMethod: NetworkStubMethod = .ANY,
        json: JSON,
        bundle: Bundle? = nil,
        jsonModifier: JsonModifier? = nil
    ) -> Stub {

        let request = NetworkStubRequest(
            url: url,
            query: query,
            excludedQuery: excludedQuery,
            httpMethod: httpMethod
        )
        let stub = Stub(request: request, response: .json(json))
        jsonModifier?(stub)
        return stub
    }
}
