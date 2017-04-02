#
# Be sure to run `pod lib lint ZiggeoSwiftSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZiggeoSwiftSDK'
  s.version          = '1.0.0'
  s.summary          = 'Ziggeo Swift Client SDK'
  s.description      = 'Ziggeo Swift recording and playback SDK'

  s.homepage         = 'http://ziggeo.com'
  s.license          = { :type => 'Confidential', :file => 'LICENSE' }
  s.author           = { 'Ziggeo Inc' => 'support@ziggeo.com' }
  s.source           = { :git => 'https://github.com/Ziggeo/Swift-Client-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.vendored_frameworks = 'Output/Swift3.1/ZiggeoSwiftFramework.framework'
  
end
