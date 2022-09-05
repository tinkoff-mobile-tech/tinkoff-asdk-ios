platform :ios, '12.3'

use_frameworks!
project './ASDKSample/ASDKSample.xcodeproj'
target 'ASDKSample' do

	pod 'TinkoffASDKCore', :path => ".", :testspecs => ['Tests']
	pod 'TinkoffASDKUI', :path => "."

	# Linting and Formatting

  pod 'SwiftFormat/CLI', '~> 0.47.2'
  pod 'SwiftLint', '~> 0.40.0'
  pod 'SwiftGen', '~> 6.0'
end
