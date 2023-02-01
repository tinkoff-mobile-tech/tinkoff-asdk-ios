Pod::Spec.new do |spec|
  spec.name = 'TinkoffASDKYandexPay'
  spec.version = '2.16.0'
  spec.summary = 'Мобильный SDK'
  spec.description = 'Позволяет настроить прием платежей в нативной форме приложений для платформы iOS с помощью YandexPaySDK'
  spec.homepage = 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS'
  spec.changelog = 'https://github.com/Tinkoff/AcquiringSdk_IOS/blob/master/CHANGELOG.md'
  spec.documentation_url = 'https://oplata.tinkoff.ru/develop/api/payments/'
  spec.license = { type: 'Apache 2.0', file: 'TinkoffASDKYandexPay/License.txt' }
  spec.author = { 'Tinkoff' => 'r.akhmadeev@tinkoff.ru' }
  spec.platform = :ios
  spec.module_name = 'TinkoffASDKYandexPay'
  spec.swift_version = '5.0'
  spec.ios.deployment_target = '12.3'
  spec.source = { git: 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS.git', tag: spec.version }
  spec.source_files = 'TinkoffASDKYandexPay/TinkoffASDKYandexPay/**/*.swift'

  spec.pod_target_xcconfig = {
    'CODE_SIGN_IDENTITY' => ''
  }

  spec.dependency 'TinkoffASDKCore'
  spec.dependency 'TinkoffASDKUI'
  spec.dependency 'YandexPaySDK/Dynamic', '~> 1.2'
end
