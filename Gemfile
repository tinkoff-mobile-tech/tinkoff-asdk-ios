source "https://nexus.tcsbank.ru/repository/ruby-gems-group-repo"

gem "cocoapods", "~> 1.11.3"
gem 'fastlane', '~> 2.204.3'
gem 'fastlane-plugin-changelog'
gem 'danger-gitlab', '~> 8.0'
gem 'danger-swiftformat', '~> 0.6'
gem 'danger-swiftlint', '~> 0.24'
gem 'rest-client'

# https://github.com/CocoaPods/CocoaPods/issues/10388
gem 'rexml', '~> 3.2.4'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)