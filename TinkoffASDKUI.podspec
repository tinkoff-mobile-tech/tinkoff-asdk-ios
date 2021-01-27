Pod::Spec.new do |spec|

	spec.name = "TinkoffASDKUI"
	spec.version = '2.2.0'
	spec.summary = 'Мобильный SDK'
	spec.description = 'Позволяет настроить прием платежей в нативной форме приложений для платформы iOS'
	spec.homepage = 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS'
	spec.documentation_url = 'https://oplata.tinkoff.ru/develop/api/payments/'
	spec.license = { :type => 'Apache 2.0', :file => 'TinkoffASDKUI/License.txt' }
	spec.author = { 'Tinkoff' => 'v.budnikov@tinkoff.ru' }
	spec.platform = :ios
	spec.module_name = "TinkoffASDKUI"
	spec.swift_version = '5.0'
	spec.ios.deployment_target = '11.0'
	spec.source = { :git => 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS.git', :tag => spec.version }
	spec.source_files = 'TinkoffASDKUI/TinkoffASDKUI/**/*.swift'
	spec.resource = "TinkoffASDKUI/TinkoffASDKUI/**/*.{lproj,strings,xib,xcassets,imageset}"
	spec.dependency 'TinkoffASDKCore'

end
