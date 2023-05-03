source "https://rubygems.org"

gem "cocoapods", "~> 1.11.3"
gem 'fastlane', '~> 2.212.2'
gem 'fastlane-plugin-changelog'

# https://github.com/CocoaPods/CocoaPods/issues/10388
gem 'rexml', '~> 3.2.4'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)