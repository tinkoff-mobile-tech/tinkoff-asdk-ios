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
- Настройки окна оплаты;

## Требования и ограничения

Для работы Tinkoff Acquiring SDK необходимо:
* Поддержка iOS 11 и выше;

## Подключение
Рекомендуется использовать [Cocoa Pods][cocoapods]. 
Для подключения добавьте в файл Podfile зависимости:
```c
pod 'TinkoffASDKCore'
pod 'TinkoffASDKUI'
```
Если вы не используете Cocoa Pods, необходимо добавить _**TinkoffASDKUI.xcodeproj**_ в проект.

## Подготовка к работе

**Важно**:
Необходимо хранить сильную ссылку на экземпляр AcquiringUISDK

Для начала работы с SDK вам понадобятся:
* **Terminal key** - терминал Продавца; 
* **Password** - пароль от терминала;
* **Public key** – публичный ключ. Используется для шифрования данных. Необходим для интеграции вашего приложения с интернет-эквайрингом Тинькофф.

Данные выдаются в личном кабинете после подключения к [Интернет-Эквайрингу][acquiring].

## Начало работы
В начале нужно создать конфигурацию, используем объект AcquiringSdkConfiguration, обязательные параметры:
* **credential**: _**AcquiringSdkCredential**_ - учетные данные, полученные в личном кабинете
* **serverEnvironment**: _**AcquiringSdkEnvironment**_ - тестовый или боевой сервер

Дополнительные параметры которые можно установить:
* **logger** - Интерфейс для логирование работы, есть реализация по умолчанию _**LoggerDelegate**_ форматированный вывод данных о работе SDK в консоль
* **language** - Язык платежной формы. На каком языке сервер будет присылать тексты ошибок клиенту.
* **showErrorAlert**: _**Bool**_ - Показывать ошибки после выполнения запроса системным _**UIAlertViewController**_

после инициализации SDK им можно пользоваться и вызывать форму для оплаты, и список карт.

Для проведения оплаты в модуле _**TinkoffASDKUI/AcquiringUISDK**_ реализованы методы для сценрия оплаты. Доступны:
* **presentPaymentView(paymentData:** _**PaymentInitData**_**)** показать форму оплаты для выброра источника оплаты (сохраненная карта или реквизиты новой) и оплатить 
* **presentPaymentView(paymentData:** _**PaymentInitData**_**, parentPatmentId:** _**Int64**_**)** быстрая оплата, оплатить рекурентный/ругулярный платеж.  
* **presentPaymentSBP(paymentData:** _**PaymentInitData**_**)** оплаить использую _**Систему Быстрых Платежей**_
* **presentPaymentAcceptanceQR()** сгенерировать и показать QR-код для приема платежей
* **paymentApplePay(paymentData:** _**PaymentInitData**_**)** оплатить используя _**ApplePay**_

Для работы со списком сохраненных карты реализован метод:
* **presentCardList** показать список сохраненных карт, и отредактировать список карт -  добавить карту, удалить карту.

### Проведение оплаты
#### Инициализация платежа
Для проведения оплаты нужно сформировать информацию о платеже используем струкруту  _**PaymentInitData**_:
* **amount:**_**Int64**_. Сумма в копейках. Например, сумма 3руб. 12коп. это число `312`. Параметр должен быть равен сумме всех товаров в чеке;
* **orderId:**_**String**_. Номер заказа в системе Продавца;
* **customerKey:**_**String**_. Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт;
* **description:**_**String**_. Краткое описание покупки;
* **payType:**_**PayType**_. Тип проведения платежа;
* **savingAsParentPayment:**_**Bool**_. Если передается и установлен в `true`, то регистрирует платёж как рекуррентный (родительский);
* **paymentFormData:**_**[String: String]**_. `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`.`Key: String` – 20 знаков, `Value: String` – 100 знаков. Максимальное количество пар параметров не может превышать 20;
* **receipt:**_**Receipt**_. Данные чека;
* **shops:**_**[Shop]**_. Информация о магазинах;
* **receipts:**_**[Receipt]**_. Информация о чеках для онлайн магазинов.
* **redirectDueDate:**_**Date?**_. Cрок жизни ссылки.

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
// терминал и пароль
let credentional = AcquiringSdkCredential(terminalKey: ASDKStageTestData.terminalKey, password: ASDKStageTestData.terminalPassword, publicKey: ASDKStageTestData.testPublicKey)
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

[acquiring]: https://oplata.tinkoff.ru
[applepay]: https://developer.apple.com/documentation/passkit/apple_pay
[cocoapods]: https://cocoapods.org
[img-pay]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen.png
[img-pay2]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen2.png
[img-pay3]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen3.png
[img-attachCard]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/attachCardScreen.png
[server-api]: https://oplata.tinkoff.ru/develop/api/payments/
[issues]: https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios/issues
