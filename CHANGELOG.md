# Changelog
## [Unreleased]

### Changed

* [MIC-6194] SPB Feature is False by default in AcquiringViewConfiguration.FeaturesOptions

### Added 

* [MIC-5741] Integrate 3ds-app-based flow
* [MIC-6228] Add 3ds-app-based feature flag

## [2.10.0] - 2022-08-31Z

### Changed

* [MIC-5966] CardList screen redesign
* [MIC-6089] Card selection logic on Payment Form

### Fixed

* [MIC-5967] Add successURL and failURL parameters to PaymentInitData model
* [MIC-6123] Add software_version and device_model parameters to Init request

### Added

* [MIC-6176] Add status, paymentId, orderId, amount properties to AcquiringResponse

## [2.9.1] - 2022-08-19Z

### Fixed

* [MIC-6177] - Card field's input mask for PAN's with dynamic length

## [2.9.0] - 2022-08-12Z

### Fixed

* [MIC-6099] The payment button touch handling in the payment form, with a recurring payment

## [2.8.1] - 2022-08-05Z

### Fixed

* [MIC-6021] Fix logger's crash
* [MIC-6012] Flickering buttons in the payment form

## [2.8.0] - 2022-07-04

## Added
* parameter shouldValidateCardExpiryDate for validateCardExpiredDate method

## Updated
* changed default behavior for shouldValidateCardExpiryDate parameter to false

## [2.7.0] - 2022-04-29

## Updated
* rename TinkoffLogger method to log

## Added
* TinkoffPay(MIC-4863)

## [2.6.7] - 2022-04-26

## Fixed
* fixed incorrect module for some classes in xibs

## [2.6.6] - 2021-03-25

## Fixed
* sbp close callback issue(MIC-4782)

## Added
* sbp payment status polling limit(MIC-4817)

## [2.6.5] - 2021-03-18

## Added
* add parameter to configure pullup fullscreen behaviour
* add pullup close completion closure(MIC-4824) 

## [2.6.4] - 2021-02-22

## Added
* connection type and SDK version with every request
* SBP fixes

## [2.6.3] - 2021-02-09

## Updated
* sbp - call callback with cancelled state on no banks app screen(MIC-4624)

## Fixed
* added missed completion call in AcquiringUISDK for SBP(https://github.com/Tinkoff/AcquiringSdk_IOS/pull/112)

## [2.6.2] - 2021-01-26

### Updated
* handle SBP bank selection cancellation
* poll payment status when open bank application

## [2.6.1] - 2021-01-21

### Updated
* using resource_bundles instead of resources in podspec

## [2.6.0] - 2021-12-19

### Added
* add sending the PayType parameter to the Init method 
* add completion handler to urlSBPPaymentViewController AcquiringUISDK method

## [2.5.1] - 2021-12-06

### Updated
* remove base64 encoding paddings for creq and ThreeDSMethod
* add mir support to default apple pay configuration

## [2.5.0] - 2021-07-27

### Updated
* remove password from SDK
* remove token building and usage for API requests

## [2.4.3] - 2021-06-17

### Added
* add rexml gem to Gemfile
* dispatch handleError call on main queue in handleSPBUrlCreation method

## [2.4.2] - 2021-06-07

### Fixed
* call completion in pushToNavigationStackAndActivate if was called more than once(https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/74)

## [2.4.1] - 2021-05-28

### Fixed
* open SBP information on no available banks screen

## [2.4.0] - 2021-05-27

### Added
* sbp bank selection sheet

## [2.3.0] - 2021-05-18

### Fixed
* rename `parent` case to `parent` in `Taxation` and fix incorrect key in init

### Added
* add `Style` to be able to customize big button style on add card and payment screens(https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/63)

## [2.2.2] - 2021-02-22

### Fixed
* issue with random amount checking presentation for 3DSHold card check type
* fix AddNewCardViewController's memory leak 

## [2.2.1] - 2021-02-09

### Fixed
* issue with 3ds webview presentation while add card

## [2.2.0] - 2021-01-27

### Fixed
* fix AcquiringPaymentViewController's memory leak

### Updated
* make CustomerKey optional (MIC-2386)
* remove public method cancelPayment from AcquiringSdk

## [2.1.5] - 2021-01-17

### Updated
* add new Item struct init method to be able to init Item with russian ruble pennies.
* deprecate Item struct init with NSDecimalNumber type for amount and price
(MIC-2384/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/11/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/31)

## [2.1.4] - 2020-12-29

### Fixed
* update close logic in PopUpViewContoller (MIC-2393/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/15)

## [2.1.3] - 2020-12-13

### Added
* add requestsTimeoutInterval parameter to AcquiringSdkConfiguration with default value (MIC-2395/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/12)
* add all Item model's parameters to init (MIC-2384/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/17)

### Fixed
* cards without parentPaymentId presentation while perform recurrent payment
* issues with cvc validation for standart and recurrent payment (MIC-2391/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/10)
* freeze after card scanner finished work (MIC-2391/https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/14)

## [2.1.2] - 2020-12-10

### Fixed
* dark mode fix: background/tint colors for SBP button and payment logos image(MIC-2392)

## [2.1.1] - 2020-10-20

### Updated
* add ability to call payment methods with existed PaymentId

## [2.1.0] - 2020-10-15

### Fixed
* changed orderId property type to String in PaymentInitData, PaymentInitResponse, PaymentInvoiceQRCodeResponse and PaymentStatusResponse(https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/7)
* make only card cells editable on CardViewController(https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS/issues/6)
* add redirectDueDate parameter to Init request
