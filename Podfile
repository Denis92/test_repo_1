use_frameworks!
inhibit_all_warnings!
workspace 'ForwardLeasing'
platform :ios, '12.0'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/SumSubstance/Specs.git'

def shared_pods
  pod 'SwiftLint'
  pod 'R.swift'
  pod 'SwiftyBeaver'
  pod 'SnapKit'
  pod 'KeychainAccess'
  pod 'Alamofire'
  pod 'PromiseKit'
  pod 'Kingfisher'
  pod 'NotificationBannerSwift'
  pod 'SumSubstanceKYC/Liveness3D'
  pod 'YandexMapsMobile', ’4.0.0-lite’
  pod ‘FLDiagnostic’, :git => ‘https://github.com/blinovarcsinus/FLDiagnostic.git’
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
end

target 'ForwardLeasing' do
  shared_pods
end

target 'ForwardLeasingTests' do
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
