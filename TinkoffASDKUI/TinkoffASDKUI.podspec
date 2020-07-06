Pod::Spec.new do |spec|

	spec.name = "TinkoffASDKUI"
	spec.version = '2.0.0'
	spec.summary = 'Мобильный SDK'
	spec.description = 'Позволяет настроить прием платежей в нативной форме приложений для платформы iOS'
	spec.homepage = 'https://oplata.tinkoff.ru/landing/develop/documentation'
	spec.license = { :type => "Apache 2.0" }
	spec.author = { "v.budnikov" => "v.budnikov@tinkoff.ru" }
	spec.platform = :ios
	spec.ios.deployment_target = '11.0'
	spec.source = { :git => 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS.git', :tag => '#{spec.version}' }
	spec.source_files = 'TinkoffASDKUI', 'TinkoffASDKUI/**/*.{swift}'
	spec.resource = "TinkoffASDKUI/**/*.{lproj,strings,xib,xcassets,imageset}"
	spec.dependency "TinkoffASDKCore"

end
