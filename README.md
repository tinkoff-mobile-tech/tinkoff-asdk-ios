# Tinkoff Acquiring SDK for iOS

Acquiring SDK позволяет интегрировать Интернет-Эквайринг в мобильные приложения для платформы iOS.

## Возможности SDK

- Прием платежей (в том числе рекуррентных);
- Сохранение банковских карт клиента;
- Работа с привязанными картами;
- Поддержка английского;
- Интеграция с онлайн-кассами;
- Оплата с помощью ApplePay;
- Оплата с помощью Системы Быстрых Платежей;
- Оплата с помощью TinkoffPay;
- Настройки окна оплаты;

## Требования и ограничения

Для работы Tinkoff Acquiring SDK необходимо:
* Поддержка iOS 12.3 и выше;

## Подключение

### Cocoapods

Для подключения добавьте в файл `Podfile` зависимости:
```c
pod 'TinkoffASDKCore'
pod 'TinkoffASDKUI'
```

### Swift Package Manager

1. Используя `Package.swift`
   
	Чтобы интегрировать AcquiringSdk в ваш проект используя `Package.swift` нужно указать зависимость.

	```swift
	dependencies: [
   	 .package(url: "https://github.com/Tinkoff/AcquiringSdk_IOS.git", .upToNextMajor(from: "2.10.1"))
	]
	```
1. Через Xcode

	File -> Add packages -> https://github.com/Tinkoff/AcquiringSdk_IOS.git
   
Выберите нужные библиотеки:
* **TinkoffASDKCore** - если вам нужен только Core функционал без UI части.
* **TinkoffASDKUI** - уже включает в себя Core часть. Полное sdk - Core + UI часть.
  
![spm-products][img-spm-products]

## Подготовка к работе

**Важно**:
Необходимо хранить сильную ссылку на экземпляр AcquiringUISDK

Для начала работы с SDK вам понадобятся:
* **Terminal key** - терминал Продавца; 
* **Public key** – публичный ключ. Используется для шифрования данных. Необходим для интеграции вашего приложения с интернет-эквайрингом Тинькофф.

Данные выдаются в личном кабинете после подключения к [Интернет-Эквайрингу][acquiring].

## Начало работы
В начале нужно создать конфигурацию, используем объект AcquiringSdkConfiguration, обязательные параметры:
* **credential**: _**AcquiringSdkCredential**_ - учетные данные, полученные в личном кабинете
* **serverEnvironment**: _**AcquiringSdkEnvironment**_ - тестовый или боевой сервер

Дополнительные параметры которые можно установить:
* **logger** - Интерфейс для логирование работы, есть реализация по умолчанию _**LoggerDelegate**_ форматированный вывод данных о работе SDK в консоль
* **language** - Язык платежной формы. На каком языке сервер будет присылать тексты ошибок клиенту.
* **showErrorAlert**: _**Bool**_ - Показывать ошибки после выполнения запроса системным _**UIAlertViewController**
* **tokenProvider**: _**ITokenProvider**_ - протокол, предоставляющий токен для подписи запроса в API эквайринга. Необходим только для терминалов, с включенной проверкой токена

после инициализации SDK им можно пользоваться и вызывать форму для оплаты, и список карт.

Для проведения оплаты в модуле _**TinkoffASDKUI/AcquiringUISDK**_ реализованы методы для сценрия оплаты. Доступны:
* **presentPaymentView(paymentData:** _**PaymentInitData**_**)** показать форму оплаты для выброра источника оплаты (сохраненная карта или реквизиты новой) и оплатить 
* **presentPaymentView(paymentData:** _**PaymentInitData**_**, parentPatmentId:** _**Int64**_**)** быстрая оплата, оплатить рекурентный/ругулярный платеж.  
* **presentPaymentSBP(paymentData:** _**PaymentInitData**_**)** оплаить использую _**Систему Быстрых Платежей**_
* **presentPaymentAcceptanceQR()** сгенерировать и показать QR-код для приема платежей
* **paymentApplePay(paymentData:** _**PaymentInitData**_**)** оплатить используя _**ApplePay**_

Для работы со списком сохраненных карты реализован метод:
* **presentCardList** показать список сохраненных карт, и отредактировать список карт -  добавить карту, удалить карту.

### Предоставление токена для подписи запросов
Если ваш терминал поддерживает валидацию токена, присылаемого в запросах к API эквайринга, то необходимо реализовать протокол `ITokenProvider` и передать его в `AcquiringSdkConfiguration`:

```swift
func provideToken(
	forRequestParameters parameters: [String: String], // Параметры, участвующие в генерации токена
	completion: @escaping (Result<String, Error>) -> Void // Замыкание, которое необходимо вызвать, передав результат генерации токена
)
```

Для генерации токена необходимо:

* Добавить пароль от терминала в словарь с ключом `Password`,
* Отсортировать пары ключ-значение по ключам в алфавитном порядке
* Конкатенировать значения всех пар
* Для полученной строки вычислить хэш SHA-256

[Подробнее о подписи запроса](https://www.tinkoff.ru/kassa/develop/api/request-sign/)

#### Пример

В простейшем случае реализация может выглядеть следующим образом:

```swift

func provideToken(forRequestParameters parameters: [String: String], completion: @escaping (Result<String, Error>) -> Void) {
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

> Важно: Реализация выше приведена исключительно в качестве примера. В целях  безопасности не стоит хранить и как бы то ни было взаимодействовать с паролем от терминала в коде мобильного приложения. Наиболее подходящий сценарий - передавать полученные параметры на бекенд, где будет происходить генерация токена на основе параметров и пароля

### Проведение оплаты

#### Инициализация платежа

Для проведения оплаты нужно сформировать информацию о платеже используем струкруту  **PaymentInitData**:

* **amount: Int64** - Сумма в копейках. Например, сумма 3руб. 12коп. это число `312`. Параметр должен быть равен сумме всех товаров в чеке

* **orderId: String** - Номер заказа в системе Продавца

* **customerKey: String** - Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт

* **description: String** - Краткое описание покупки

* **payType: PayType** - Тип проведения платежа

* **savingAsParentPayment: Bool** - Если передается и установлен в `true`, то регистрирует платёж как рекуррентный (родительский)

* **paymentFormData: [String: String]** - `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`.`Key: String` – 20 знаков, `Value: String` – 100 знаков. Максимальное количество пар параметров не может превышать 20

* **receipt: Receipt** - Данные чека

* **shops: [Shop]** - Информация о магазинах

* **receipts: [Receipt]** - Информация о чеках для онлайн магазинов

* **redirectDueDate: Date?** - Cрок жизни ссылки

* **successURL: String?** - URL на веб-сайте продавца, куда будет переведен покупатель в случае успешной оплаты (настраивается в Личном кабинете). Если параметр передан – используется его значение. Если нет – значение в настройках терминала

* **failURL: String?** - URL на веб-сайте продавца, куда будет переведен покупатель в случае неуспешной оплаты (настраивается в Личном кабинете). Если параметр передан – используется его значение. Если нет – значение в настройках терминала

#### Начало платежа

Далее вызываем метод _**AcquiringUISDK.presentPaymentView**_. Перед началом оплаты открывается форма оплаты товара и запускается метод _**Init**_ 
результатом которого является регистрация и получение информации о платеже для оплаты _**PaymentInitResponse**_:
* **success:**_**Bool**_ - статус обработки запроса;
* **errorCode:**_**Int**_ - номер ошибки в случае неуспешной инициализации платежа, по умолчанию 0;
* **errorMessage:**_**String?**_ - описание ошибки;
* **errorDetails:**_**String?**_ - детальное описание ошибки;
* **terminalKey:**_**String?**_ - идентификатор терминала на котором инициализирован платеж;
* **amount:**_**Int64**_ - сумма платежа в копейках;
* **orderId:**_**String**_ - номер заказа в системе продавца;
* **paymentId:**_**Int64**_ - номер для оплаты в системе банка;
* **status:**_**PaymentStatus**_ - статус платежа, [подробнее][https://oplata.tinkoff.ru/landing/develop/documentation/processing_payment]. В случае удачной регистрации платежа на форме оплаты показываются список карт, карточка ввода реквизитов новой карты и кнопка Оплатить. Пользователь выбирает карту, либо вводит реквизиты новой нажимает и нажимает Оплатить.

#### Завершение платежа
Вызывается метод _**FinishAuthorize**_ с реквизитами карты или _**FinishAuthorize**_ с номером ранее сохраненной карты.
Во время проведения платежа сервер может запросить подтверждение  в этом случае пользователю показывается форма 3D Secure в зависимости от выбранного источника оплаты, это решение принимается сервером. 

### PaymentController (AcquiringUISDK)
**PaymentController** - позволяет совершать оплату (без вью части) только бизнес логика.
```swift
  public func paymentController(
        uiProvider: PaymentControllerUIProvider,
        delegate: PaymentControllerDelegate,
        dataSource: PaymentControllerDataSource? = nil
    ) -> PaymentController
```

#### TinkoffPay

Для работы с TinkoffPay необходимо добавить в Info.plist в массив по ключу `LSApplicationQueriesSchemes` значение `tinkoffbank`.

```
<key>LSApplicationQueriesSchemes</key>
<array>
	***
  <string>tinkoffbank</string>
  ***
</array>
```

**TinkoffPay на экране оплаты**

При открытии экрана оплаты SDK проверит наличие возможности оплаты через TinkoffPay и, в зависимости от результата, отобразит кнопку оплаты. 
Отключить отображение кнопки программно можно с помощью параметра `tinkoffPayEnabled` в `featuresOptions` в конфигурации `AcquiringViewConfiguration`.


Совершить платеж можно через общий экран оплаты, вызвав метод у экземпляра `AcquiringUISDK`.

```
func presentPaymentView(on presentingViewController: UIViewController,
                       acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
                       configuration: AcquiringViewConfiguration,
                       tinkoffPayDelegate: TinkoffPayDelegate?,
                       completionHandler: @escaping PaymentCompletionHandler)
```

В момент показа экрана оплаты, будет совершен запрос, который проверит, доступна ли оплата через TinkoffPay для вашего терминала и в случае доступности отобразится кнопка для совершения оплаты.

Для определения возможности оплаты через TinkoffPay SDK посылает запрос на https://securepay.tinkoff.ru/v2/TinkoffPay/terminals/$terminalKey/status.

Ответ на запрос кэшируется на некоторое время. Значение по-умолчанию 300 секунд. Его можно сконфигурировать через параметр `tinkoffPayStatusCacheLifeTime` у объекта`AcquiringSdkConfiguration`, который используется при инициализации `AcquiringUISDK`.

Посредством реализации протокола `TinkoffPayDelegate` можно получит сообщение о том, что оплата через Tinkoff Pay недоступна.

Можно сконфигурировать стиль кнопки TinkoffPay через параметр `tinkoffPayButtonStyle` у `AcquiringViewConfiguration`.

**TinkoffPay внутри вашего приложения**

Для отображения кнопки оплаты через Tinkoff Pay внутри вашего приложения (вне экрана оплаты, предоставляемого SDK) необходимо:

1. Самостоятельно вызвать метод определения доступности оплаты через Tinkoff Pay. Для этого можно использовать метод 
```
func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void)
```
2. При наличии возможности оплаты отобразить кнопку оплаты через Tinkoff Pay в вашем приложении.
3. По нажатию кнопки вызвать метод(параметр `GetTinkoffPayStatusResponse.Status.Version` получен на 1 шаге) и показать полученный из метода ViewController.
```
func tinkoffPayViewController(acquiringPaymentStageConfiguration: AcquiringPaymentStageConfiguration,
                              configuration: AcquiringViewConfiguration,
                              version: GetTinkoffPayStatusResponse.Status.Version,
                              completionHandler: PaymentCompletionHandler? = nil) -> UIViewController
```
Задача по закрытию ViewController, полученный из метода, ложится на плечи пользователя в момент вызова `completionHandler`.

##### API

Если необходимо использовать отдельно методы API для TinkoffPay:
У экземпляра `AcquiringSdk` можно вызвать:

Для проверки доступности TinkoffPay на терминале

```
func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void)
```

Для получения deeplink

```
func getTinkoffPayLink(paymentId: Int64,
                       version: GetTinkoffPayStatusResponse.Status.Version,
                       completion: @escaping (Result<GetTinkoffLinkResponse, Error>) -> Void)
```



##### Кнопка TinkoffPay

Для отрисовки кнопки существует класс `TinkoffPayButton`.

При инициализации можно указать требуемый стиль кнопки.



При использовании этого инициализатора, у кнопки будет фиксированный стиль.

```
init(style: TinkoffPayButton.Style)
```

В случае использовании этого инициализатора, можно указать отдельно стиль для светлой и темной темы.

```
init(dynamicStyle: TinkoffPayButton.DynamicStyle)
```



### Подключение сканера

для сканера нужно использовать любое стронее решение, подключение сканера к SDK осуществляется  через _**AcquiringViewConfigration.**_**scaner** - это ссылка на объект который реализует протокол _**CardRequisitesScanerProtocol**_

```swift
protocol CardRequisitesScanerProtocol: class {
  func startScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void)
}
```
пример использования:

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


### Пример работы
Оплата товара по реквизитам карты или с ранее сохраненной карты

```swift
AcquiringUISDK.presentPaymentView(on presentingViewController: UIViewController, 
								paymentData: PaymentInitData, 
								configuration: AcquiringViewConfigration,
								completionHandler: @escaping PaymentCompletionHandler)

```
Оплата товара через Apple Pay

```swift
AcquiringUISDK.presentPaymentApplePay(on presentingViewController: UIViewController,
									paymentData data: PaymentInitData,
									viewConfiguration: AcquiringViewConfigration,
									paymentConfiguration: AcquiringUISDK.ApplePayConfiguration,
									completionHandler: @escaping PaymentCompletionHandler)

```
Список сохраненных карт 

```swift
AcquiringUISDK.presentCardList(on: self, customerKey: customerKey, configuration: cardListViewConfigration)
```
Пример создания экземпляра sdk:
```swift
// терминал
let credentional = AcquiringSdkCredential(terminalKey: ASDKStageTestData.terminalKey, publicKey: ASDKStageTestData.testPublicKey)
// конфигурация для старта sdk
let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credentional)		
// включаем логи, результаты работы запросов пишутся в консоль 
acquiringSDKConfiguration.logger = AcquiringLoggerDefault()

if let sdk = try? AcquiringUISDK.init(configuration: acquiringSDKConfiguration) {
	// SDK проинициализировалось, можно приступать к работе
	sdk.present ...
}
```
Пример создание AcquiringViewConfigration:
```swift
let viewConfigration = AcquiringViewConfigration.init()
// подключаем сканер
viewConfigration.scaner = scaner
// Формируем поля для экрана оплаты
viewConfigration.fields = []
// Заголовок в UINavigationBar, для случая когда экран оплаты раскрыт на весь экран
viewConfigration.viewTitle = NSLocalizedString("title.pay", comment: "Оплата")
// 1. Заголовок экрана "Оплата на сумму хх.хх руб."
let title = NSAttributedString.init(string: NSLocalizedString("title.paymeny", comment: "Оплата"), attributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
let amountString = Utils.formatAmount(NSDecimalNumber.init(floatLiteral: productsAmount()))
let amountTitle = NSAttributedString.init(string: "\(NSLocalizedString("text.totalAmount", comment: "на сумму")) \(amountString)", attributes: [.font : UIFont.systemFont(ofSize: 17)])
// fields.append
viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.amount(title: title, amount: amountTitle))

// 2. Описание товаров которые оплачиваем
let productsDetatils = NSMutableAttributedString.init()
productsDetatils.append(NSAttributedString.init(string: "Книги\n", attributes: [.font : UIFont.systemFont(ofSize: 17)]))
let productsDetails = products.map { (product) -> String in
  return product.name
}.joined(separator: ", ")
productsDetatils.append(NSAttributedString.init(string: productsDetails, attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor(red: 0.573, green: 0.6, blue: 0.635, alpha: 1)]))
viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.detail(title: productsDetatils))

// 3. Добавляем поле email 
if AppSetting.shared.showEmailField {
  viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.email(value: nil, placeholder: NSLocalizedString("plaseholder.email", comment: "Отправить квитанцию по адресу")))
}

// 4. Кнопка для оплаты используя Систему Быстрых Платежей
if AppSetting.shared.paySBP {
  viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.buttonPaySPB)
}
// На каком яэыке отображется экран оплаты
viewConfigration.localizableInfo = AcquiringViewConfigration.LocalizableInfo.init(lang: AppSetting.shared.languageId)
```
### Кастомизация

Для того что бы кастомизировать UI компонента(цвет кнопки оплатить и т.д.), необходимо реализовать протокол `Style` и передать его экземпляр как параметр `style` при инициализации объекта SDK. 

```
import TinkoffASDKUI

struct MyAwesomeStyle: Style {
...
}
```

```
if let sdk = try? AcquiringUISDK(configuration: acquiringSDKConfiguration, 
				 style: MyAwesomeStyle()) {
...
}
```

### ASDKSample
Содержит пример интеграции Tinkoff Acquiring SDK в мобильное приложение по продаже книг.
Главный экран список заготовок товаров.
Второй экран - детали товара и выбор сбособа оплаты.




### Поддержка
- Просьба, по возникающим вопросам обращаться на oplata@tinkoff.ru
- Баги и feature-реквесты можно направлять в раздел [issues][issues]
- Документация на сайте, описание [API методов][server-api]

[acquiring]: https://www.tinkoff.ru/kassa/
[applepay]: https://developer.apple.com/documentation/passkit/apple_pay
[cocoapods]: https://cocoapods.org
[img-spm-products]: Docs/images/spm_products.png
[img-pay]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen.png
[img-pay2]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen2.png
[img-pay3]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen3.png
[img-attachCard]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/attachCardScreen.png
[server-api]: https://oplata.tinkoff.ru/develop/api/payments/
[issues]: https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios/issues
