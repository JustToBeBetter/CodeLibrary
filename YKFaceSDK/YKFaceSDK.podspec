#
# Be sure to run `pod lib lint YKFaceSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YKFaceSDK'
  s.version          = '0.1.5'
  s.summary          = '人脸跟踪和特效SDK'
  s.description      = '人脸跟踪和特效SDK'

  s.homepage         = 'https://code.dobest.com/ios/YKFaceSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'toss156' => '308276366@qq.com' }
  s.source           = { :git => 'git@code.dobest.com:ios/YKFaceSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.module_name = 'YKFaceSDK'
  s.source_files = 'YKFaceSDK/Classes/*', 'YKFaceSDK/Classes/**/*', 'YKFaceSDK/Classes/**/**/*'
  
  s.resources = ['YKFaceSDK/Assets/faceModel.bundle', 'YKFaceSDK/Assets/faceStickers.bundle', 'YKFaceSDK/Assets/tnn.bundle']

  s.public_header_files = 'YKFaceSDK/Classes/*.h', 'YKFaceSDK/Classes/Filter/*.h', 'YKFaceSDK/Classes/Sticker/*.h'
  s.frameworks = 'UIKit', 'AVFoundation', 'CoreVideo', 'CoreMedia', 'CoreImage', 'Metal', 'CoreML', 'Accelerate'

  s.ios.vendored_frameworks = 'YKFaceSDK/Lib/tnn.framework', 'YKFaceSDK/Lib/opencv2.framework'

  s.xcconfig = {
    'ENABLE_BITCODE' => 'NO',
  }
  
  s.dependency 'GPUImage'
  s.dependency 'SSZipArchive'
  
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
