# Changelog
## [Unreleased]

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
