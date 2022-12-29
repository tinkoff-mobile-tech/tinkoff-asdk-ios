# Интеграция `Yandex Pay` с `Тинькофф Эквайринг`

`TinkoffASDKYandexPay` - модуль, позволяющий установить кнопку оплаты `Yandex Pay` в ваше приложение и начать прием платежей от пользователей с помощью `Тинькофф Эквайринг`.

## Требования и ограничения

Для работы `TinkoffASDKYandexPay` необходимо:

- Поддержка iOS 12.3 и выше
- Подключение через Сocoapods (Swift Package Manager для данного модуля на данный момент недоступен)

## Подключение

### Cocoapods

Для подключения добавьте в `Podfile` зависимость:

```ruby
pod 'TinkoffASDKYandexPay'
```

## Подготовка к работе

`TinkoffASDKYandexPay` работает на базе библиотеки `YandexPaySDK`. В этой секции по шагам расписан алгоритм ее настройки.

> :warning: **Важно выполнить все шаги, в противном случае вас ждет runtime crash при инициализации `YandexPaySDK`**

> :warning: **Не рекомендуется использовать `TinkoffASDKYandexPay` и `YandexPaySDK` или иные библиотеки зависящие от `YandexPaySDK` в рамках одного приложения так как могут возникнуть непредвиденные ошибки**

### Шаг 1. Зарегистрируйте приложение

Зарегистрируйте ваше приложение на [Яндекс.OAuth](https://oauth.yandex.ru)

### Шаг 2. Настройте Info.plist

Добавьте в Info.plist следующие строки:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>yandexauth</string>
    <string>yandexauth2</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>YandexLoginSDK</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yx<Client id of your application></string>
        </array>
    </dict>
</array>
```

В приведенном выше примере необходимо прописать `ClientId` своего приложения. В тестовом приложении ASDKSample это выглядит следующим образом:

```xml
<key>CFBundleURLSchemes</key>
    <array>
        <string>yx9dc6814e39204c638222dede9561ea6f</string>
    </array>
```

### Шаг 3. Настройте Entitlements

`YandexPaySDK` общается с приложениями Яндекса через Universal Links. Для их работы добавьте в `Capability: Associated Domains` строку `applinks:yx{идентификатор клиентского приложения в системе Яндекс}.oauth.yandex.ru`.

В нашем тестовом приложении `ASDKSample` приведен пример подобной настройки.

Например, идентификатор нашего приложения - `9dc6814e39204c638222dede9561ea6f`, добавляемая строка выглядит так: `applinks:yx9dc6814e39204c638222dede9561ea6f.oauth.yandex.ru`

## Интеграция в приложение

### Шаг 1. Отправка событий из `AppDelegate`

Вам необходимо настроить отправку событий из методов жизненного цикла приложения в `TinkoffASDKYandexPay`:

```swift
import TinkoffASDKYandexPay

func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    YandexPayApplicationEventsReceiver.applicationDidReceiveUserActivity(userActivity)
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    YandexPayApplicationEventsReceiver.applicationDidReceiveOpen(url, sourceApplication: options[.sourceApplication] as? String)
    return true
}

func applicationWillEnterForeground(_ application: UIApplication) {
    YandexPayApplicationEventsReceiver.applicationWillEnterForeground()
}

func applicationDidBecomeActive(_ application: UIApplication) {
    YandexPayApplicationEventsReceiver.applicationDidBecomeActive()
}
```

### Шаг 2. Получение фабрики для создания кнопки

В созданном классе `AcquiringUISDK` вызовите метод `yandexPayButtonContainerFactory(configuration: completion)`. На этом этапе произойдет запрос в `Тинькофф Эквайринг API` для проверки доступности данного способа оплаты и получения параметров для инициализации `YandexPaySDK`. Полученную таким образом фабрику можно переиспользовать сколь угодно раз для создания кнопки `YandexPay`:

```swift
import TinkoffASDKUI
import TinkoffASDKYandexPay

let sdk: AcquiringUISDK = ...

let configuration = YandexPaySDKConfiguration(environment: .production, locale: .system)

sdk.yandexPayButtonContainerFactory(with: configuration) { [weak self] result in
    guard let self = self else { return }

    switch result {
    case let .success(factory):
        self.setupView(with: factory)
    case let .failure(error):
        /// Ваш терминал не поддерживает прием платежей через `Yandex Pay` или на этапе инициализации произошла ошибка
        break
    }
}
```

### Шаг 3. Создание кнопки из фабрики

С помощью фабрики `IYandexPayButtonContainerFactory` создайте кнопку с необходимой конфигурацией и добавьте ее в свой UI:

```swift
import TinkoffASDKUI
import TinkoffASDKYandexPay

func setupView(with factory: IYandexPayButtonContainerFactory) {
    let theme = YandexPayButtonContainerTheme(
        appearance: .dark, 
        dynamic: true
    )

    let buttonConfiguration = YandexPayButtonContainerConfiguration(theme: theme)

    let button = factory.createButtonContainer(
        with: buttonConfiguration,
        delegate: self
    )
    
    // Стандартный cornerRadius кнопки - 8. При необходимости его можно изменить 
    button.layer.cornerRadius = 15

    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    // Привяжите кнопку к view необходимым образом и при желании задайте размеры.
    // Кнопка умеет растягиваться/сжиматься, адаптируя свой внутренний контент под заданные размеры.
    // Без указания размеров кнопка будет иметь стандартную высоту/ширину
    NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
        button.widthAnchor.constraint(equalToConstant: 300) 
    ])
}
```

### Шаг 4. Реализуйте протокол `YandexPayButtonContainerDelegate`

Для взаимодействия с кнопкой необходимо реализировать методы протокола `YandexPayButtonContainerDelegate`. Для примера сделаем это в некотором `UIViewController`:

```swift
extension MyViewController: YandexPayButtonContainerDelegate {
    func yandexPayButtonContainer(
         _ container: IYandexPayButtonContainer,
         didRequestPaymentSheet completion: @escaping (YandexPayPaymentSheet?) -> Void
    ) {
        let orderOption: OrderOptions = ...
        let customerOptions: CustomerOptions = ...

        let paymentOptions = PaymentOptions(
            orderOptions: orderOptions,
            customerOptions: customerOptions
        )

        let paymentSheet = YandexPayPaymentSheet(paymentOptions: paymentOptions)

        // Может быть вызван синхронно или асинхронно из любого потока
         completion(paymentSheet)
    }

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(
        _ container: IYandexPayButtonContainer
    ) -> UIViewController? {
        self
     }

    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didCompletePaymentWithResult result: YandexPayPaymentResult
    ) {
        // Обработайте результат оплаты на свое усмотрение
        switch result {
        case .cancelled:
            print("Payment is cancelled by user")
        case let .succeeded(info):
            print("Payment completed successfully with amount \(info.paymentOptions.orderOptions.amount)")
        case let .failed(error):
            print("Payment completed with error \(error)")
        }
    }
}
```
