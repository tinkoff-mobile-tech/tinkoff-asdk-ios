# Tinkoff Acquiring SDK for iOS

Acquiring SDK позволяет интегрировать Интернет-Эквайринг в мобильные приложения для платформы iOS.

## Возможности SDK

- Прием платежей (в том числе рекуррентных)
- Сохранение банковских карт клиента
- Работа с привязанными картами
- Поддержка английской локализации
- Интеграция с онлайн-кассами
- Оплата с помощью ApplePay
- Оплата с помощью Системы Быстрых Платежей
- Оплата с помощью TinkoffPay
- Конфигурация формы оплаты

## Требования и ограничения

Для работы Tinkoff Acquiring SDK необходимо:

- Поддержка iOS 12.3 и выше

## Подключение

### Cocoapods

Для подключения добавьте в файл `Podfile` зависимости:

```ruby
pod 'TinkoffASDKCore'
pod 'TinkoffASDKUI'
```

### Swift Package Manager

#### Используя `Package.swift`

Чтобы интегрировать AcquiringSdk в ваш проект используя `Package.swift` нужно указать зависимость:

```swift
dependencies: [
	.package(url: "https://github.com/Tinkoff/AcquiringSdk_IOS.git", .upToNextMajor(from: "2.10.1"))
]
```

#### Через Xcode

File -> Add packages -> `https://github.com/Tinkoff/AcquiringSdk_IOS.git`

Выберите нужные библиотеки:

- **TinkoffASDKCore** - если вам нужен только Core функционал без UI части.

- **TinkoffASDKUI** - уже включает в себя Core часть. Полное sdk - Core + UI часть.

<p align="center">
	<img src=Docs/images/spm_products.png>
</p>

## Подготовка к работе

> :warning: **Необходимо хранить сильную ссылку на экземпляр AcquiringUISDK**

Для начала работы с SDK вам понадобятся:

- **Terminal key** - терминал Продавца
- **Public key** – публичный ключ. Используется для шифрования данных. Необходим для интеграции вашего приложения с интернет-эквайрингом Тинькофф.

Данные выдаются в личном кабинете после подключения к [Интернет-Эквайрингу][acquiring].

## Начало работы

В начале нужно создать конфигурацию, используем объект AcquiringSdkConfiguration, обязательные параметры:

- **credential**: **AcquiringSdkCredential** - учетные данные, полученные в личном кабинете
- **serverEnvironment**: **AcquiringSdkEnvironment** - тестовый или боевой сервер

Дополнительные параметры которые можно установить:

- **logger** - Интерфейс для логирование работы. Есть реализация по умолчанию - **LoggerDelegate**, форматирующий и выводящий данные о работе SDK в консоль
- **language** - Язык платежной формы. На каком языке сервер будет присылать тексты ошибок клиенту.
- **showErrorAlert**: **Bool** - Показывать ошибки после выполнения запроса системным **UIAlertViewController**
- **tokenProvider**: **ITokenProvider** - протокол, предоставляющий токен для подписи запроса в API эквайринга. Необходим только для терминалов, с включенной проверкой токена

После инициализации SDK им можно пользоваться и вызывать форму для оплаты, и список карт.

Для проведения оплаты в модуле **TinkoffASDKUI/AcquiringUISDK** реализованы методы для различных сценариев оплаты. Доступны:

- **presentPaymentView(paymentData: PaymentInitData)** - показать форму оплаты для выбора источника оплаты (сохраненная карта или реквизиты новой) и оплатить
- **presentPaymentView(paymentData: PaymentInitData, parentPatmentId Int64)** быстрая оплата, оплатить рекуррентный/регулярный платеж.  
- **presentPaymentSBP(paymentData: PaymentInitData)** оплатить используя **Систему Быстрых Платежей**
- **presentPaymentAcceptanceQR()** - сгенерировать и показать QR-код для приема платежей
- **paymentApplePay(paymentData: PaymentInitData)** - оплатить используя **ApplePay**

Для работы со списком сохраненных карты реализован метод:

- **presentCardList** показать список сохраненных карт, и отредактировать список карт -  добавить карту, удалить карту.

### Предоставление токена для подписи запросов

Если ваш терминал поддерживает валидацию токена, присылаемого в запросах к API эквайринга, то необходимо реализовать протокол `ITokenProvider` и передать его в `AcquiringSdkConfiguration`:

```swift
func provideToken(
	forRequestParameters parameters: [String: String], // Параметры, участвующие в генерации токена
	completion: @escaping (Result<String, Error>) -> Void // Замыкание, которое необходимо вызвать, передав результат генерации токена
)
```

Для генерации токена необходимо:

- Добавить пароль от терминала в словарь с ключом `Password`
- Отсортировать пары ключ-значение по ключам в алфавитном порядке
- Конкатенировать значения всех пар
- Для полученной строки вычислить хэш SHA-256

[Подробнее о подписи запроса](https://www.tinkoff.ru/kassa/develop/api/request-sign/)

#### Пример

В простейшем случае реализация может выглядеть следующим образом:

```swift
func provideToken(
	forRequestParameters parameters: [String: String],
	completion: @escaping (Result<String, Error>) -> Void
) {
	let sourceString = parameters
		.merging(["Password": password]) { $1 }
		.sorted { $0.key < $1.key }
		.map(\.value)
		.joined()

	let hashingResult = Result {
		try SHA256.hash(from: sourceString)
	}

	completion(hashingResult)
}
```

> :warning: **Реализация выше приведена исключительно в качестве примера**. В целях  безопасности не стоит хранить и как бы то ни было взаимодействовать с паролем от терминала в коде мобильного приложения. Наиболее подходящий сценарий - передавать полученные параметры на бекенд, где будет происходить генерация токена на основе параметров и пароля

### Форма оплаты с вводом реквизитов карты и ранее сохраненными картами

Для отображения формы оплаты необходимо вызвать метод `AcquiringUISDK.presentPaymentView`:

```swift
public func presentPaymentView(
	on presentingViewController: UIViewController,
	customerKey: String? = nil,
	acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
	configuration: AcquiringViewConfiguration,
	tinkoffPayDelegate: TinkoffPayDelegate? = nil,
	completionHandler: @escaping PaymentCompletionHandler
)
```

 По завершении платежа будет вызван `completionHandler` с `Result<PaymentStatusResponse, Error>`, в котором в случае успеха будут содержаться данные:

- **success: Bool** - статус обработки запроса
- **errorCode: Int** - номер ошибки в случае неуспешной инициализации платежа, по умолчанию 0
- **errorMessage: String?** - описание ошибки
- **errorDetails: String?** - детальное описание ошибки
- **terminalKey: String?** - идентификатор терминала на котором инициализирован платеж
- **amount: Int64** - сумма платежа в копейках
- **orderId: String** - номер заказа в системе продавца
- **paymentId: Int64** - номер для оплаты в системе банка
- **status: PaymentStatus** - статус платежа. В случае удачной регистрации платежа на форме оплаты показываются список карт, карточка ввода реквизитов новой карты и кнопка Оплатить. Пользователь выбирает карту, либо вводит реквизиты новой нажимает и нажимает Оплатить

В методе выбор стадии платежа осуществляется с помощью `AcquiringPaymentStageConfiguration`. Далее рассмотрим доступные стадии

#### Оплата с инициацией платежа

В этом сценарии ASDK самостоятельно вызывает метод `Init` API эквайринга при совершении оплаты, передавая информацию о платеже, заданных в **PaymentInitData**:

- **amount: Int64** - Сумма в копейках. Например, сумма 3руб. 12коп. это число `312`. Параметр должен быть равен сумме всех товаров в чеке
- **orderId: String** - Номер заказа в системе Продавца
- **customerKey: String** - Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт
- **description: String** - Краткое описание покупки
- **payType: PayType** - Тип проведения платежа
- **savingAsParentPayment: Bool** - Если передается и установлен в `true`, то регистрирует платёж как рекуррентный (родительский)
- **paymentFormData: [String: String]** - `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`.`Key: String` – 20 знаков, `Value: String` – 100 знаков. Максимальное количество пар параметров не может превышать 20
- **receipt: Receipt** - Данные чека
- **shops: [Shop]** - Информация о магазинах
- **receipts: [Receipt]** - Информация о чеках для онлайн магазинов
- **redirectDueDate: Date?** - Срок жизни ссылки
- **successURL: String?** - URL на веб-сайте продавца, куда будет переведен покупатель в случае успешной оплаты (настраивается в Личном кабинете). Если параметр передан – используется его значение. Если нет – значение в настройках терминала
- **failURL: String?** - URL на веб-сайте продавца, куда будет переведен покупатель в случае неуспешной оплаты (настраивается в Личном кабинете). Если параметр передан – используется его значение. Если нет – значение в настройках терминала

```swift
let paymentData: PaymentInitData = ...
let paymentStageConfiguration = AcquiringPaymentStageConfiguration(paymentStage: .`init`(paymentData: paymentData))
```

#### Оплата на основе существующего `paymentId`

В этом сценарии метод `Init` API эквайринга вызывается вне SDK, например на бекенде клиентского приложения. Затем в SDK эквайринга полученный `paymentId` передается с помощью:

```swift
let paymentId: Int64 = ...

let paymentStageConfiguration = AcquiringPaymentStageConfiguration(paymentStage: .finish(paymentId: paymentId))
```

#### TinkoffPay

Для работы с TinkoffPay необходимо добавить в Info.plist в массив по ключу `LSApplicationQueriesSchemes` значение `tinkoffbank`.

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tinkoffbank</string>
</array>
```

##### Кнопка TinkoffPay на форме оплаты

При открытии экрана оплаты SDK проверит наличие возможности оплаты через TinkoffPay и, в зависимости от результата, отобразит кнопку оплаты. 
Отключить отображение кнопки программно можно с помощью параметра `tinkoffPayEnabled` в `featuresOptions` в конфигурации `AcquiringViewConfiguration`.

Совершить платеж можно через общий экран оплаты, вызвав метод у экземпляра `AcquiringUISDK`.

```swift
func presentPaymentView(
	on presentingViewController: UIViewController,
    acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
    configuration: AcquiringViewConfiguration,
    tinkoffPayDelegate: TinkoffPayDelegate?,
    completionHandler: @escaping PaymentCompletionHandler
)
```

В момент показа экрана оплаты, будет совершен запрос, который проверит, доступна ли оплата через TinkoffPay для вашего терминала и в случае доступности отобразится кнопка для совершения оплаты.

Для определения возможности оплаты через TinkoffPay SDK посылает запрос на https://securepay.tinkoff.ru/v2/TinkoffPay/terminals/$terminalKey/status.

Ответ на запрос кэшируется на некоторое время. Значение по-умолчанию 300 секунд. Его можно сконфигурировать через параметр `tinkoffPayStatusCacheLifeTime` у объекта`AcquiringSdkConfiguration`, который используется при инициализации `AcquiringUISDK`.

Посредством реализации протокола `TinkoffPayDelegate` можно получит сообщение о том, что оплата через Tinkoff Pay недоступна.

Можно сконфигурировать стиль кнопки TinkoffPay через параметр `tinkoffPayButtonStyle` у `AcquiringViewConfiguration`.

##### Кнопка TinkoffPay внутри вашего приложения

Для отображения кнопки оплаты через Tinkoff Pay внутри вашего приложения (вне экрана оплаты, предоставляемого SDK) необходимо:

1. Самостоятельно вызвать метод определения доступности оплаты через Tinkoff Pay. Для этого можно использовать метод:

```swift
func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void)
```

2. При наличии возможности оплаты отобразить кнопку оплаты через Tinkoff Pay в вашем приложении

3. По нажатию кнопки вызвать метод(параметр `GetTinkoffPayStatusResponse.Status.Version` получен на 1 шаге) и показать полученный из метода ViewController

```swift
func tinkoffPayViewController(
	acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
    configuration: AcquiringViewConfiguration,
    version: GetTinkoffPayStatusResponse.Status.Version,
    completionHandler: PaymentCompletionHandler? = nil) -> UIViewController
)
```

Задача по закрытию ViewController, полученный из метода, ложится на плечи пользователя в момент вызова `completionHandler`.

##### API

Если необходимо использовать отдельно методы API для TinkoffPay:
У экземпляра `AcquiringSdk` можно вызвать:

Для проверки доступности TinkoffPay на терминале

```swift
func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void)
```

Для получения deeplink

```swift
func getTinkoffPayLink(
	paymentId: Int64,
    version: GetTinkoffPayStatusResponse.Status.Version,
    completion: @escaping (Result<GetTinkoffLinkResponse, Error>) -> Void
)
```

##### Кнопка TinkoffPay

Для отрисовки кнопки существует класс `TinkoffPayButton`.

При инициализации можно указать требуемый стиль кнопки.

При использовании этого инициализатора, у кнопки будет фиксированный стиль.

```swift
init(style: TinkoffPayButton.Style)
```

В случае использовании этого инициализатора, можно указать отдельно стиль для светлой и темной темы.

```swift
init(dynamicStyle: TinkoffPayButton.DynamicStyle)
```

### Подключение сканера

для сканера нужно использовать любое стороннее решение, подключение сканера к SDK осуществляется через **AcquiringViewConfiguration.scaner** - это ссылка на объект который реализует протокол **CardRequisitesScanerProtocol**

```swift
protocol CardRequisitesScanerProtocol: class {
  func startScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void)
}
```

Пример использования:

```swift
extension RootViewController: AcquiringScanerProtocol {
	func presentScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void) -> UIViewController? {
		if let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CardScanerViewController") as? CardScanerViewController {
      		viewController.onScannerResult = { (numbres) in
      			completion(numbres, nil, nil)
			}
			
    		return viewController
		}
		
		return nil
	}
}
```

### Оплата товара через Apple Pay

```swift
presentPaymentApplePay(
	on presentingViewController: UIViewController,
	paymentData data: PaymentInitData,
	viewConfiguration: AcquiringViewConfiguration,
	paymentConfiguration: AcquiringUISDK.ApplePayConfiguration,
	completionHandler: @escaping PaymentCompletionHandler
)
```

### Отобразить список сохраненных карт

```swift
public func presentCardList(
	on presentingViewController: UIViewController,
	customerKey: String,
	configuration: AcquiringViewConfiguration
)
```

### Пример создания экземпляра SDK

```swift
// терминал
let credential = AcquiringSdkCredential(terminalKey: ASDKStageTestData.terminalKey, publicKey: ASDKStageTestData.testPublicKey)
// конфигурация для старта sdk
let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credential)
// включаем логи, результаты работы запросов пишутся в консоль 
acquiringSDKConfiguration.logger = AcquiringLoggerDefault()

if let sdk = try? AcquiringUISDK.init(configuration: acquiringSDKConfiguration) {
	// SDK проинициализировалось, можно приступать к работе
}
```

### Пример создание `AcquiringViewConfiguration`

```swift
let viewConfiguration = AcquiringViewConfiguration()
// подключаем сканер
viewConfiguration.scaner = scaner
// Формируем поля для экрана оплаты
viewConfiguration.fields = []
// Заголовок в UINavigationBar, для случая когда экран оплаты раскрыт на весь экран
viewConfiguration.viewTitle = NSLocalizedString("title.pay", comment: "Оплата")
// 1. Заголовок экрана "Оплата на сумму хх.хх руб."
let title = NSAttributedString(string: NSLocalizedString("title.payment", comment: "Оплата"), attributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
let amountString = Utils.formatAmount(NSDecimalNumber(floatLiteral: productsAmount()))
let amountTitle = NSAttributedString(string: "\(NSLocalizedString("text.totalAmount", comment: "на сумму")) \(amountString)", attributes: [.font : UIFont.systemFont(ofSize: 17)])
// fields.append
viewConfiguration.fields.append(AcquiringViewConfiguration.InfoFields.amount(title: title, amount: amountTitle))

// 2. Описание товаров которые оплачиваем
let productsDetails = NSMutableAttributedString()
productsDetails.append(NSAttributedString(string: "Книги\n", attributes: [.font : UIFont.systemFont(ofSize: 17)]))

let productsDetails = products.map { (product) -> String in
  return product.name
}.joined(separator: ", ")

productsDetails.append(NSAttributedString(string: productsDetails, attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor(red: 0.573, green: 0.6, blue: 0.635, alpha: 1)]))
viewConfiguration.fields.append(AcquiringViewConfiguration.InfoFields.detail(title: productsDetails))

// 3. Добавляем поле email 
if AppSetting.shared.showEmailField {
  viewConfiguration.fields.append(AcquiringViewConfiguration.InfoFields.email(value: nil, placeholder: NSLocalizedString("placeholder.email", comment: "Отправить квитанцию по адресу")))
}

// 4. Кнопка для оплаты используя Систему Быстрых Платежей
if AppSetting.shared.paySBP {
  viewConfiguration.fields.append(AcquiringViewConfiguration.InfoFields.buttonPaySPB)
}
```

### Кастомизация

Для того что бы кастомизировать UI компонента(цвет кнопки оплатить и т.д.), необходимо реализовать протокол `Style` и передать его экземпляр как параметр `style` при инициализации объекта SDK.

```swift
import TinkoffASDKUI

struct MyAwesomeStyle: Style {
...
}
```

```swift
let sdk = try AcquiringUISDK(configuration: acquiringSDKConfiguration style: MyAwesomeStyle())
```

### ASDKSample

Содержит пример интеграции Tinkoff Acquiring SDK в мобильное приложение по продаже книг.
Главный экран список заготовок товаров.
Второй экран - детали товара и выбор способа оплаты.

### Поддержка

- Просьба, по возникающим вопросам обращаться на oplata@tinkoff.ru
- Баги и feature-реквесты можно направлять в раздел [issues][issues]
- Документация на сайте, описание [API методов][server-api]

[acquiring]: https://www.tinkoff.ru/kassa/
[applepay]: https://developer.apple.com/documentation/passkit/apple_pay
[cocoapods]: https://cocoapods.org
[img-pay]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen.png
[img-pay2]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen2.png
[img-pay3]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen3.png
[img-attachCard]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/attachCardScreen.png
[server-api]: https://oplata.tinkoff.ru/develop/api/payments/
[issues]: https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios/issues
