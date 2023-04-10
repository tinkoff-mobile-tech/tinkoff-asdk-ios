Pod::Spec.new do |spec|

	spec.name = "TinkoffASDKUI"
	spec.version = '3.1.0'
	spec.summary = 'Мобильный SDK'
	spec.description = 'Позволяет настроить прием платежей в нативной форме приложений для платформы iOS'
	spec.homepage = 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS'
	spec.changelog = 'https://github.com/Tinkoff/AcquiringSdk_IOS/blob/master/CHANGELOG.md'
	spec.documentation_url = 'https://oplata.tinkoff.ru/develop/api/payments/'
	spec.license = { :type => 'Apache 2.0', :file => 'TinkoffASDKUI/License.txt' }
	spec.author = { 'Tinkoff' => 'v.budnikov@tinkoff.ru' }
	spec.platform = :ios
	spec.module_name = "TinkoffASDKUI"
	spec.swift_version = '5.0'
	spec.ios.deployment_target = '12.3'
	spec.source = { :git => 'https://github.com/TinkoffCreditSystems/AcquiringSdk_IOS.git', :tag => spec.version }
	spec.source_files = 'TinkoffASDKUI/TinkoffASDKUI/**/*.swift'
  	spec.resource_bundles = {
    	'TinkoffASDKUIResources' => ['TinkoffASDKUI/TinkoffASDKUI/**/*.{lproj,strings,xib,xcassets,imageset,png}']
  	}
	spec.pod_target_xcconfig = { 
		'CODE_SIGN_IDENTITY' => '' 
	}
	spec.dependency 'TinkoffASDKCore'
    spec.vendored_frameworks = ['ThirdParty/ThreeDSWrapper.xcframework', 'ThirdParty/TdsSdkIos.xcframework']
    spec.preserve_paths = ['ThirdParty/ThreeDSWrapper.xcframework', 'ThirdParty/TdsSdkIos.xcframework']
  
    spec.resources = [
    	'ThirdParty/TdsSdkIos.xcframework/ios-arm64/TdsSdkIos.framework/TdsSdkIosResources.bundle',
    	'ThirdParty/ThreeDSWrapper.xcframework/ios-arm64/ThreeDSWrapper.framework/ThreeDSWrapperResources.bundle'
    ]
  
	spec.test_spec 'Tests' do |test_spec|
	test_spec.source_files = 
	'TinkoffASDKUI/TinkoffASDKUITests/**/*', 
	'TinkoffASDKCore/TinkoffASDKCoreTests/Infrastructure/**/*'
	end
end
