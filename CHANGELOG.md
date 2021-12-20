# Changelog
## [Unreleased]

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
