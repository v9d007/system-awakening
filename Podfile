# Podfile for System: Awakening
platform :ios, '17.0'
use_frameworks!

target 'SystemAwakening' do
  # Pods for SystemAwakening can be added here
  # Example: pod 'Lottie', '~> 4.4'

  target 'SystemAwakeningTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      # Enable Swift Strict Concurrency for modern toolchains
      config.build_settings['SWIFT_STRICT_CONCURRENCY'] = 'complete'
    end
  end
end
