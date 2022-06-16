# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'ssh://git@47.110.64.20:7999/app/bltuikitspecrepo.git'
target 'LBUIProject' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LBUIProject
  pod 'Masonry', '~> 1.1.0'
  pod 'FaceAware'
#  升级到1.0.6 处理M1芯片电脑  不支持arm64模拟器的
  pod 'LookinServer', '= 1.0.6', :configurations => ['Debug']
  pod 'BLTBasicUIKit'
  pod 'BLTUIKitProject'
#  pod 'QMUIKit'
  pod 'MBProgressHUD'
  pod 'MMKV'
  pod 'BLTSwiftUIKit'
  pod 'AvoidCrash', '~>2.5.2'
  pod 'CHTCollectionViewWaterfallLayout/ObjC', '= 0.9.10'
  pod 'JXPagingView/Pager'
#  pod 'WechatOpenSDK', '1.9.2'
#  pod 'charts', :git => 'https://github.com/danielgindi/Charts.git', :tag => '3.6.0'
  target 'LBUIProjectTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LBUIProjectUITests' do
    # Pods for testing
  end

end
