platform :ios, '12.3'

use_frameworks!
project './ASDKSample/ASDKSample.xcodeproj'
target 'ASDKSample' do

	pod 'TinkoffASDKCore', :path => ".", :testspecs => ['Tests']
	pod 'TinkoffASDKUI', :path => "."

	# Linting and Formatting

  pod 'SwiftFormat/CLI', '~> 0.49.18'
  pod 'SwiftLint', '0.47.0' # Версия должна совпадать с версией на CI
  pod 'SwiftGen', '~> 6.0'
end

def install_githooks
  system("git config --local core.hooksPath \"$(git rev-parse --show-toplevel)/githooks\"")
end

post_install do |installer|
  install_githooks
end