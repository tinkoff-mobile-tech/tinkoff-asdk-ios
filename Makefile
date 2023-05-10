start:
	cd 'ASDKSample'; bundle exec pod install || bundle exec pod install --repo-update
	open ASDKSample/ASDKSample.xcworkspace;