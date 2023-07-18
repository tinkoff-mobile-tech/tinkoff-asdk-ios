Pod::Spec.new do |spec|
  
  spec.name = 'TinkoffASDKCore'
  spec.version = '3.1.1'
  spec.summary = 'Мобильный SDK'
  spec.description = 'Позволяет настроить прием платежей в нативной форме приложений для платформы iOS'
  spec.homepage = 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS'
  spec.changelog = 'https://github.com/Tinkoff/AcquiringSdk_IOS/blob/master/CHANGELOG.md'
  spec.documentation_url = 'https://oplata.tinkoff.ru/develop/api/payments/'
  spec.license = { :type => 'Apache 2.0', :file => 'TinkoffASDKCore/License.txt' }
  spec.author = { 'Tinkoff' => 'v.budnikov@tinkoff.ru' }
  spec.platform = :ios
  spec.module_name = "TinkoffASDKCore"
  spec.swift_version = '5.0'
  spec.ios.deployment_target = '12.3'
  spec.static_framework = true
  spec.source = { :git => 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS.git', :tag => spec.version }
  spec.source_files = 'TinkoffASDKCore/TinkoffASDKCore/**/*.swift'
  spec.resource_bundles = {
    'TinkoffASDKCoreResources' => ['TinkoffASDKCore/TinkoffASDKCore/**/*.{lproj,strings,der}']
  }
  spec.pod_target_xcconfig = {
    'CODE_SIGN_IDENTITY' => ''
  }
  
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'TinkoffASDKCore/TinkoffASDKCoreTests/**/*.swift'
    test_spec.exclude_files = 'TinkoffASDKCore/TinkoffASDKCoreTests/IntegrationTests.swift', 'TinkoffASDKCore/TinkoffASDKCoreTests/FinishResponseTests.swift', 'TinkoffASDKCore/TinkoffASDKCoreTests/CoreTests.swift'
    test_spec.resources = 'TinkoffASDKCore/TinkoffASDKCoreTests/**/*.{json}'
  end
end
