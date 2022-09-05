#
# Be sure to run `pod lib lint ZiggeoSwiftSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guidespec.cocoapodspec.org/syntax/podspec.html
#

Pod::Spec.new do |spec|

  spec.name             = 'ZiggeoSwiftSDK'
  spec.version          = '1.1.38-blurring'
  spec.summary          = 'Ziggeo Swift Client SDK'
  spec.description      = 'Ziggeo Swift recording and playback SDK'

  spec.homepage         = 'http://ziggeo.com'
  spec.license          = { :type => 'Confidential', :file => 'LICENSE' }
  spec.author           = { 'Ziggeo Inc' => 'support@ziggeo.com' }
  spec.source           = { :git => 'https://github.com/Ziggeo/Swift-Client-SDK.git', :tag => spec.version.to_s }

  spec.swift_version    = '5.0'
  spec.platform         = :ios, '11.0'

  spec.ios.deployment_target = '11.0'
  spec.vendored_frameworks = 'ZiggeoSwiftSDK/SelfieSegmentation.framework', 'ZiggeoSwiftSDK/ZiggeoSwiftFramework.framework'

end
