// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Loc {
  internal enum Alert {
    internal enum Message {
      /// Операция отменена
      internal static let addingCardCancel = Loc.tr("Localizable", "alert.message.addingCardCancel", fallback: "Операция отменена")
    }
    internal enum Title {
      /// Карта добавлена
      internal static let cardSuccessAdded = Loc.tr("Localizable", "alert.title.cardSuccessAdded", fallback: "Карта добавлена")
    }
  }
  internal enum Button {
    /// Вернуться в магазин
    internal static let backToShop = Loc.tr("Localizable", "button.backToShop", fallback: "Вернуться в магазин")
    /// Отменить
    internal static let cancel = Loc.tr("Localizable", "button.cancel", fallback: "Отменить")
    /// Закрыть
    internal static let close = Loc.tr("Localizable", "button.close", fallback: "Закрыть")
    /// Готово
    internal static let done = Loc.tr("Localizable", "button.done", fallback: "Готово")
    /// Сгенерировать QR-код
    internal static let generateQRCode = Loc.tr("Localizable", "button.generateQRCode", fallback: "Сгенерировать QR-код")
    /// OK
    internal static let ok = Loc.tr("Localizable", "button.ok", fallback: "OK")
    /// Оплатить
    internal static let pay = Loc.tr("Localizable", "button.pay", fallback: "Оплатить")
    /// Оплатить, начать регулярный платеж
    internal static let payAndSaveAsParent = Loc.tr("Localizable", "button.payAndSaveAsParent", fallback: "Оплатить, начать регулярный платеж")
    /// Повторить платеж
    internal static let paymentTryAgain = Loc.tr("Localizable", "button.paymentTryAgain", fallback: "Повторить платеж")
    /// Выбрать другую карту
    internal static let selectAnotherCard = Loc.tr("Localizable", "button.selectAnotherCard", fallback: "Выбрать другую карту")
  }
  internal enum Credentials {
    internal enum Buttons {
      /// Active
      internal static let active = Loc.tr("Localizable", "credentials.buttons.active", fallback: #"Active"#)
      /// Добавить
      internal static let add = Loc.tr("Localizable", "credentials.buttons.add", fallback: #"Добавить"#)
    }
    internal enum Settings {
      /// Изменить SDK Credentials
      internal static let changeCreds = Loc.tr("Localizable", "credentials.settings.changeCreds", fallback: #"Изменить SDK Credentials"#)
      /// ASDK Credentials
      internal static let header = Loc.tr("Localizable", "credentials.settings.header", fallback: #"ASDK Credentials"#)
    }
    internal enum Viewcontroller {
      /// Sdk Credentials
      internal static let title = Loc.tr("Localizable", "credentials.viewcontroller.title", fallback: #"Sdk Credentials"#)
    }
  }
  internal enum CredentialsView {
    internal enum Title {
      /// Customer Key
      internal static let customerKey = Loc.tr("Localizable", "credentialsView.title.customerKey", fallback: #"Customer Key"#)
      /// Delete
      internal static let delete = Loc.tr("Localizable", "credentialsView.title.delete", fallback: #"Delete"#)
      /// Description
      internal static let descriptiom = Loc.tr("Localizable", "credentialsView.title.descriptiom", fallback: #"Description"#)
      /// Edit
      internal static let edit = Loc.tr("Localizable", "credentialsView.title.edit", fallback: #"Edit"#)
      /// Name
      internal static let name = Loc.tr("Localizable", "credentialsView.title.name", fallback: #"Name"#)
      /// Public Key
      internal static let publicKey = Loc.tr("Localizable", "credentialsView.title.publicKey", fallback: #"Public Key"#)
      /// Save
      internal static let save = Loc.tr("Localizable", "credentialsView.title.save", fallback: #"Save"#)
      /// Terminal Key
      internal static let terminalKey = Loc.tr("Localizable", "credentialsView.title.terminalKey", fallback: #"Terminal Key"#)
      /// Terminal Password
      internal static let terminalPassword = Loc.tr("Localizable", "credentialsView.title.terminalPassword", fallback: #"Terminal Password"#)
    }
  }
  internal enum Error {
    internal enum Camera {
      /// Не найдена камера.
      internal static let noSessionFound = Loc.tr("Localizable", "error.camera.noSessionFound", fallback: "Не найдена камера.")
      /// Пресет не поддерживается
      internal static let preset = Loc.tr("Localizable", "error.camera.preset", fallback: "Пресет не поддерживается")
      /// Ошибка камеры
      internal static let setup = Loc.tr("Localizable", "error.camera.setup", fallback: "Ошибка камеры")
      internal enum Preset {
        /// Пресет камеры не поддерживается. Пожалуйста, попробуйте другой.
        internal static let message = Loc.tr("Localizable", "error.camera.preset.message", fallback: "Пресет камеры не поддерживается. Пожалуйста, попробуйте другой.")
      }
    }
    internal enum Device {
      /// Произошла ошибка настройки устройства
      internal static let setup = Loc.tr("Localizable", "error.device.setup", fallback: "Произошла ошибка настройки устройства")
    }
  }
  internal enum Name {
    /// Acquiring
    internal static let acquiring = Loc.tr("Localizable", "name.acquiring", fallback: "Acquiring")
    /// TinkoffPay
    internal static let tinkoffPay = Loc.tr("Localizable", "name.tinkoffPay", fallback: "TinkoffPay")
  }
  internal enum Plaseholder {
    /// Отправить квитанцию по адресу
    internal static let email = Loc.tr("Localizable", "plaseholder.email", fallback: "Отправить квитанцию по адресу")
  }
  internal enum Status {
    /// Корзина пуста
    internal static let cartIsEmpty = Loc.tr("Localizable", "status.cartIsEmpty", fallback: "Корзина пуста")
    internal enum Alert {
      /// Системные
      internal static let off = Loc.tr("Localizable", "status.alert.off", fallback: "Системные")
      /// Acquiring SDK
      internal static let on = Loc.tr("Localizable", "status.alert.on", fallback: "Acquiring SDK")
    }
    internal enum Sbp {
      /// Выключены
      internal static let off = Loc.tr("Localizable", "status.sbp.off", fallback: "Выключены")
      /// Включены
      internal static let on = Loc.tr("Localizable", "status.sbp.on", fallback: "Включены")
    }
    internal enum ShowEmailField {
      /// Скрыто
      internal static let off = Loc.tr("Localizable", "status.showEmailField.off", fallback: "Скрыто")
      /// Показывать
      internal static let on = Loc.tr("Localizable", "status.showEmailField.on", fallback: "Показывать")
    }
  }
  internal enum Text {
    /// Родительский платеж
    internal static let parentPayment = Loc.tr("Localizable", "text.parentPayment", fallback: "Родительский платеж")
    /// Покупка на сумму
    internal static let paymentStatusAmount = Loc.tr("Localizable", "text.paymentStatusAmount", fallback: "Покупка на сумму")
    /// отменена
    internal static let paymentStatusCancel = Loc.tr("Localizable", "text.paymentStatusCancel", fallback: "отменена")
    /// прошла успешно.
    internal static let paymentStatusSuccess = Loc.tr("Localizable", "text.paymentStatusSuccess", fallback: "прошла успешно.")
    /// Показать на платежной форме поле для ввода email куда будет отправлен чек полсе оплаты
    internal static let showEmailField = Loc.tr("Localizable", "text.showEmailField", fallback: "Показать на платежной форме поле для ввода email куда будет отправлен чек полсе оплаты")
    /// на сумму
    internal static let totalAmount = Loc.tr("Localizable", "text.totalAmount", fallback: "на сумму")
    internal enum Acquiring {
      /// Использовать AlertView системный или из Acquiring SDK
      internal static let description = Loc.tr("Localizable", "text.Acquiring.description", fallback: "Использовать AlertView системный или из Acquiring SDK")
    }
    internal enum AddCardCheckType {
      /// NO – сохранить карту без проверок. Родительский платеж в случае успеха не создастся.
      /// 3DS – при сохранении карты выполнить проверку 3DS и выполнить списание, а затем отмену на 1 р. Карты, не поддерживающие 3DS, привязаны не будут. В случае успеха сгенерируется родительский платеж, для рекуррентных платежей.
      /// HOLD – при сохранении сделать списание и затем отмену на 1 руб. В случае успеха сгенерируется родительский платеж для рекуррентных платежей.
      /// 3DSHOLD – при привязке карты выполняем проверку, поддерживает карта 3DS или нет. Если карта поддерживает 3DS выполняем списание и затем отмену на 1 руб.
      internal static let description = Loc.tr("Localizable", "text.addCardCheckType.description", fallback: "NO – сохранить карту без проверок. Родительский платеж в случае успеха не создастся.\n3DS – при сохранении карты выполнить проверку 3DS и выполнить списание, а затем отмену на 1 р. Карты, не поддерживающие 3DS, привязаны не будут. В случае успеха сгенерируется родительский платеж, для рекуррентных платежей.\nHOLD – при сохранении сделать списание и затем отмену на 1 руб. В случае успеха сгенерируется родительский платеж для рекуррентных платежей.\n3DSHOLD – при привязке карты выполняем проверку, поддерживает карта 3DS или нет. Если карта поддерживает 3DS выполняем списание и затем отмену на 1 руб.")
    }
    internal enum Language {
      /// auto - Устанавливается язык который выбран на устройстве.
      /// ru - Платежная форма на Русском языке.
      /// en - Платежная форма на Англисйком языке.
      internal static let description = Loc.tr("Localizable", "text.language.description", fallback: "auto - Устанавливается язык который выбран на устройстве.\nru - Платежная форма на Русском языке.\nen - Платежная форма на Англисйком языке.")
    }
    internal enum PayBySBP {
      /// на главном экране кнопка сгенерировать QR-код для приема платежей, на форме платежей добавляеся кнопка оплатить с помощью СБП
      internal static let description = Loc.tr("Localizable", "text.payBySBP.description", fallback: "на главном экране кнопка сгенерировать QR-код для приема платежей, на форме платежей добавляеся кнопка оплатить с помощью СБП")
    }
  }
  internal enum Title {
    /// Уведомления, алерты
    internal static let acquiring = Loc.tr("Localizable", "title.Acquiring", fallback: "Уведомления, алерты")
    /// AlertView
    internal static let aquaringAlertView = Loc.tr("Localizable", "title.aquaringAlertView", fallback: "AlertView")
    /// Корзина
    internal static let cart = Loc.tr("Localizable", "title.cart", fallback: "Корзина")
    /// Система Быстрых Платежей
    internal static let fasterPayments = Loc.tr("Localizable", "title.fasterPayments", fallback: "Система Быстрых Платежей")
    /// Товары
    internal static let goods = Loc.tr("Localizable", "title.goods", fallback: "Товары")
    /// Онлайн магазин
    internal static let onlineShop = Loc.tr("Localizable", "title.onlineShop", fallback: "Онлайн магазин")
    /// Оплата
    internal static let pay = Loc.tr("Localizable", "title.pay", fallback: "Оплата")
    /// Оплатить, начать регулярный платеж
    internal static let payAndSaveAsParent = Loc.tr("Localizable", "title.payAndSaveAsParent", fallback: "Оплатить, начать регулярный платеж")
    /// Оплатить с помощью ApplePay
    internal static let payByApplePay = Loc.tr("Localizable", "title.payByApplePay", fallback: "Оплатить с помощью ApplePay")
    /// Оплатить с помощью Системы Быстрых Платежей
    internal static let payBySBP = Loc.tr("Localizable", "title.payBySBP", fallback: "Оплатить с помощью Системы Быстрых Платежей")
    /// Список карт
    internal static let paymentCardList = Loc.tr("Localizable", "title.paymentCardList", fallback: "Список карт")
    /// Локализация платежной формы
    internal static let paymentFormLanguage = Loc.tr("Localizable", "title.paymentFormLanguage", fallback: "Локализация платежной формы")
    /// Источник оплаты
    internal static let paymentSource = Loc.tr("Localizable", "title.paymentSource", fallback: "Источник оплаты")
    /// Повторить платеж
    internal static let paymentTryAgain = Loc.tr("Localizable", "title.paymentTryAgain", fallback: "Повторить платеж")
    /// Оплатить
    internal static let paymeny = Loc.tr("Localizable", "title.paymeny", fallback: "Оплатить")
    /// QR-код
    internal static let qrcode = Loc.tr("Localizable", "title.qrcode", fallback: "QR-код")
    /// Сохранение карты
    internal static let savingCard = Loc.tr("Localizable", "title.savingCard", fallback: "Сохранение карты")
    /// Настройки
    internal static let settings = Loc.tr("Localizable", "title.settings", fallback: "Настройки")
    /// Поле ввода email
    internal static let showEmailField = Loc.tr("Localizable", "title.showEmailField", fallback: "Поле ввода email")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
