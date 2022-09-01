Pod::Spec.new do |spec|

	spec.name = 'TinkoffASDKCore'
	spec.version = '2.10.1'
	spec.summary = 'Мобильный SDK'
	spec.description = 'Позволяет настроить прием платежей в нативной форме приложений для платформы iOS'
	spec.homepage = 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS'
	spec.documentation_url = 'https://oplata.tinkoff.ru/develop/api/payments/'
	spec.license = { :type => 'Apache 2.0', :file => 'TinkoffASDKCore/License.txt' }
	spec.author = { 'Tinkoff' => 'v.budnikov@tinkoff.ru' }
	spec.platform = :ios
	spec.module_name = "TinkoffASDKCore"
	spec.swift_version = '5.0'
	spec.ios.deployment_target = '12.3'
	spec.source = { :git => 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS.git', :tag => spec.version }
	spec.source_files = 'TinkoffASDKCore/TinkoffASDKCore/**/*.swift'
  spec.resource_bundles = {
      'TinkoffASDKCoreResources' => ['TinkoffASDKCore/TinkoffASDKCore/**/*.{lproj,strings}']
  }
  
	spec.test_spec 'Tests' do |test_spec|
    	test_spec.source_files = 'TinkoffASDKCore/TinkoffASDKCoreTests/**/*.swift'
    	test_spec.exclude_files = 'TinkoffASDKCore/TinkoffASDKCoreTests/IntegrationTests.swift', 'TinkoffASDKCore/TinkoffASDKCoreTests/FinishResponseTests.swift', 'TinkoffASDKCore/TinkoffASDKCoreTests/CoreTests.swift'
  	end  
end
