# Changelog
## [Unreleased]

### Added

* [MIC-6827] Implemented CardFieldView
* [MIC-6824] Redesigned Card List Cell
* [MIC-6825] Card List Screen Redesign
* [MIC-6843] Card List Screen Redesign - Cards Removal
* [MIC-6837] Card List Screen Redesign - Integration
* [MIC-6841] Card List Screen Redesign - Tests
* [MIC-7538] Add New Tinkoff Bins
* [MIC-7380] SBP Redesign - without payment
* [MIC-7555] Add finish flow handling for YandexPay payments
* [MIC-7384] Add payment sheet to SBP

### Changed

* [MIC-7482] CommonSheet adoption for different states

### Fixed

* [MIC-7710] CommonSheet primary button's english localization

## [2.15.0] - 2022-12-29Z

### Added

* [MIC-6527] NetworkClient unit tests
* [MIC-6526] AcquiringAPIClient unit tests
* [MIC-6801] AcquiringRequestAdapter unit tests
* [MIC-6627] Added Tests for PaymentController
* [MIC-6700] Added Skeleton Views + Skeleton Animations
* [MIC-6817] Dynamic Icon Card View (allows to generate a card visuals)
* [MIC-6828] Added Stylable Button
* [MIC-6848] Bank detection logic based on cardNumber
* [MIC-6821] Added Snackbar for presenting snacks
* [MIC-7349] Ability to provide dismissing behavior to PullableContainer
* [MIC-4762] YandexPayButton integration
* [MIC-6875] Payment system validation for Union Pay
* [MIC-7349] Add ability to provide dismissing behavior to PullableContainer
* [MIC-6827] Implemented CardFieldView
* [MIC-6824] Redesigned Card List Cell
* [MIC-6825] Card List Screen Redesign
* [MIC-6843] Card List Screen Redesign - Cards Removal
* [MIC-6837] Card List Screen Redesign - Integration
* [MIC-6841] Card List Screen Redesign - Tests
* [MIC-6833] Add New Card Screen Redisign - General Redisign
* [MIC-6834] Add New Card Screen Redisign - Card List Integration
* [MIC-6835] Add New Card Screen Redisign - Present Add Card Only Integration
* [MIC-6836] Add New Card Screen Redisign - Sample add shortcut button for presenting Add Card
* [MIC-6842] Add New Card Screen Redisign - Unit Tests
* [MIC-7538] Add New Tinkoff Bins
* [MIC-7545] Adapt CardList for Payment Card Selection Flow

### Fixed

* [MIC-6675] Submit3DSAuthorizationV2 request for 3DS App Based Flow

## [2.14.1] - 2022-12-26Z

### Added

* [MIC-7301] AuthChallengeService injection ability for URLSession and WKWebView

## [2.13.1] - 2022-12-13Z

### Fixed

* [MIC-6975] Fix readme and add info about payment stages
* [MIC-6888] Fix 3DS V2 handling for cards attaching

## [2.12.2] - 2022-10-28Z

### Changed

* [MIC-6423] Fix ASDKCore architecture after merging versions
* [MIC-6431] Remove unused entities in ASDKCore
* [MIC-6432] Dependency inversion in ASDKCore
* [MIC-6433] File structure in ASDKCore
* [MIC-6434] Adapt the network layer for different response formats in ASDKCore
* [MIC-6671] Change host for test environment to rest-api-test.tinkoff.ru
* [MIC-6671] Change public key in ASDKSample

### Added

* [MIC-6063] Implement token providing logic for ASDK requests
* [MIC-6184] Implement SampleTokenProvider in ASDKSample
* [MIC-6513+MIC-6279] Implementation of PaymentController from v3/root is now added master version. PaymentController - let's you have all the logic needed for payments without depening on UI.
* [MIC-6582] CustomerKey editing now available in ASDKSample app
* [MIC-6584] Switching terminal now available in ASDKSample app

### Fixed

* [MIC-6735] Response validation by condition `success == true && errorCode == 0`
* [MIC-6847] Rename objc method for issue #208

## [2.11.2] - 2022-10-13Z

### Fixed

* pull/198 modalViewController.popupStyle now uses configuration popupStyle (bug fix)
* [MIC-6735] Response validation by condition `success == true && errorCode == 0`

## [2.11.1] - 2022-10-10Z

### Fixed

* [MIC-6624] Remove TerminalKey providing for GET requests

## [2.11.0] - 2022-10-05Z

### Changed

* [MIC-6194] SPB Feature is False by default in AcquiringViewConfiguration.FeaturesOptions
* [MIC-6275] Swift Gen integration for TinkoffASDKUI module
* [MIC-6292] Swift Package Support & build Package.swift step for CI/CD
* [MIC-6293] Update ThreeDSWrapper to 1.0.7
* [MIC-6364] SwiftLint & SwiftFormat + Automation + Merge Request required rules
* [MIC-6210] Integrate new Network Layer & Change Public Methods in ASDKCore & Deprecate old methods
* [MIC-5908] Deleted broken xproject files, moved Podfile into ASDKSample folder
* [MIC-6276] SwiftGen for Core module + SwiftGen for Sample App

### Fixed

* [MIC-6508] GetCardList response parsing  
* [MIC-6551] CardList last card visibility
* [MIC-6567] CVC code fixed masking on add new card flow
* [MIC-6552] Successful status of card addition response when using 3ds
* [MIC-6541] Fixed Xcode 14 error Code signing bundles

## [2.10.4] - 2022-09-26Z

### Fixed

* [MIC-6445] Content Type header for 3DS Browser Based Requests

## [2.10.2] - 2022-09-13Z

### Added
* Xcode 14 support

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
