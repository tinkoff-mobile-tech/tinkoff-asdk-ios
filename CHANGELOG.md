# Changelog
## [Unreleased]
### Added
* [EACQAPW-5649] Add Tinkoff Pay Links clarification to README

## [3.1.1] - 2023-07-17Z

### Fixed
* [EACQAPW-5561] Tinkoff Pay doesn't pass SuccessURL & FailURL in /Init

## [3.1.0] - 2023-06-28Z

### Added
* [EACQAPW-4844] README corrections
* [EACQAPW-4910] README add new capabilities CardController + PaymentController
* [EACQAPW-4868] Make a Github Action to run snapshot tests
* [EACQAPW-4625] SBP Sheet tests
* [EACQAPW-4626] Qr ImageView tests
* [EACQAPW-4198] Yandex Pay Display Button Tests
* [EACQAPW-4195] Yandex Pay Interaction SDK Tests
* [EACQAPW-4194] Card List Tests
* [EACQAPW-4833] Card Payment Presenter tests
* [EACQAPW-4912] Cell Presenters tests 
* [EACQAPW-4924] BankResolver and PaymentSystemResolver Tests
* [EACQAPW-4929] TinkoffPaySheetPresenter Tests
* [EACQAPW-4930] MainFormPresenter Tests
* [EACQAPW-4931] MainFormOrderDetailsViewPresenter Tests
* [EACQAPW-4932] TinkoffPay Tests
* [EACQAPW-4193] Add Card Tests
* [EACQAPW-5016] Reccurent Tests
* [EACQAPW-5017] Cover Code Coverage on TinkoffASDKYandexPay.framework to 100%
* [EACQAPW-4761] Add New Bank Bins
* [EACQAPW-4186] Cocoapods remove autoimports of UIKit
* [EACQAPW-5207] PaymentStatusUpdateService Tests
* [EACQAPW-5208] AppChecker and TinkoffPayAppChecker Tests
* [EACQAPW-5209] MoneyFormatter Tests

### Fixed

* [MIC-7135] Properly forming query path in get url
* [EACQAPW-4593] Fixes for validation of card number
* [EACQAPW-4690] Main form keyboard notifications
* [EACQAPW-4741] Keyboard wrong appearing on AddNewCard screen
* [EACQAPW-4742] Handle unknown statuses in sbp payment sheet
* [EACQAPW-4996] Card payment proper status handles
* [EACQAPW-5231] Fix of images rendered badly (used png)
* [EACQAPW-5258] RunLoop run caused bugy getState handles
* [EACQAPW-5288] TPay Controller handle DEADLINE_EXPIRED
* [EACQAPW-5297] Fix broken pdfs

## [3.0.0] - 2023-05-12Z

### Added

* [MIC-6875] Payment system validation for Union Pay
* [MIC-6827] Implemented CardFieldView
* [MIC-6824] Redesigned Card List Cell
* [MIC-6825] Card List Screen Redesign
* [MIC-6843] Card List Screen Redesign - Cards Removal
* [MIC-6837] Card List Screen Redesign - Integration
* [MIC-6841] Card List Screen Redesign - Tests
* [MIC-7545] Adapt CardList for Payment Card Selection Flow
* [MIC-6833] Add New Card Screen Redisign - General Redisign
* [MIC-6834] Add New Card Screen Redisign - Card List Integration
* [MIC-6835] Add New Card Screen Redisign - Present Add Card Only Integration
* [MIC-6836] Add New Card Screen Redisign - Sample add shortcut button for presenting Add Card
* [MIC-6842] Add New Card Screen Redisign - Unit Tests
* [MIC-7538] Add New Tinkoff Bins
* [MIC-7380] SBP Redesign - without payment
* [MIC-7384] Add payment sheet to SBP
* [MIC-7703] MainForm - Add entry point in ASDKSample
* [MIC-7702] MainForm - MVP module foundation
* [MIC-7704] MainForm - Primary pay method block
* [MIC-7775] MainForm - SavedCard view
* [MIC-7828] MainForm - Provide payment data to CardPaymentForm
* [MIC-7827] MainForm - Extend cvc field's touch area
* [MIC-7705] MainForm - Update Button for configuring
* [MIC-7706] MainForm - Other Payment Methods
* [MIC-7952] MainForm - UI elements with own cells
* [MIC-7707] MainForm - State changes handling
* [MIC-8030] MainForm - Saved card selection
* [MIC-8093] MainForm - Add primary payment method resolving logic
* [MIC-7708] MainForm - Remove stub for primary payment method
* [MIC-8013] MainForm - Card payment logic
* [MIC-8037] MainForm - Add analytics data
* [MIC-8020] MainForm - Add localization
* [MIC-8596] MainForm - Change SBP Button's background color
* [MIC-8760] MainForm - PullableContainer's height adapts to content height
* [MIC-8761] MainForm - Keyboard handling logic takes into account the position of the button
* [MIC-7699] CardPayment - Add common functionality of payment by card
* [MIC-8068] SBP - Opening from main form
* [MIC-4650] CardsController & AddCardController for working with payment cards with own UI
* [MIC-8027] Integrate CardsController to AddNewCard module
* [MIC-8026] Integrate CardsController to CardList module
* [MIC-8050] Change add card icon
* [MIC-8095] TinkoffPay - integrate to MainForm
* [MIC-8096] TinkoffPay - integrate with independent button
* [MIC-7776] PullableContainer refactoring
* [EACQAPW-4707] Add correct sbp failures handling on MainForm
* [MIC-8723] - Design review ui fixes - Pay by new card
* [MIC-8719] - Design review ui fixes - Cards flow
* [MIC-8786] Fix keyboard handling in recurrent payment module
* [EACQAPW-4284] Testing SBPBanks module and services
* [EACQAPW-4190] - YandexPay Flow Unit Tests
* [EACQAPW-4189] - YandexPay Flow Error Handling Unit Tests
* [EACQAPW-4188] - Add documentation for Acquiring v3

### Fixed

* [EACQAPW-4762] Add PayType to PaymentOptions
* [EACQAPW-4772] Fix TinkoffPay Analytics

## [2.19.0] - 2023-04-13Z

### Added

* [EACQAPW-4510] Added public inits for `AgentData` и `SupplierInfo`

## [2.18.2] - 2023-03-28Z

### Added

* [MIC-8065] Update for Russian Certificates

## [2.17.0] - 2023-02-13Z

### Changed

* [MIC-7945] PaymentController work improvements

### Fixed

* [MIC-7956] Fix Tinkoff Pay button availability on recurrent payments

## [2.16.0] - 2023-01-19Z

### Added

* [MIC-7555] Add finish flow handling for YandexPay payments

### Changed

* [MIC-7482] CommonSheet adoption for different states

### Fixed

* [MIC-7710] CommonSheet primary button's english localization

## [2.15.1] - 2023-01-18Z

### Fixed

* [MIC-7670] Remove Apple Pay from README
* [MIC-7653] Scanner result handling

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
