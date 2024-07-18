# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'ssh://git@1.117.247.154:7999/app/bltuikitspecrepo.git'
target 'LBUIProject' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  #仿微信 头条的图片浏览
  pod 'GKPhotoBrowser', '= 2.6.3'
  pod 'Kingfisher', '~> 6.2.0'
  pod 'KingfisherWebP', '= 1.3.0'
  pod 'SnapKit', '= 4.2.0'
  # Pods for LBUIProject
  pod 'Masonry', '~> 1.1.0'
  pod 'FaceAware'
#  升级到1.0.6 处理M1芯片电脑  不支持arm64模拟器的
  pod 'LookinServer', '= 1.0.6', :configurations => ['Debug']
  pod 'BLTBasicUIKit'
  pod 'BLTUIKitProject', '= 1.9.0'
#  pod 'QMUIKit'
  pod 'MBProgressHUD'
  pod 'MMKV'
  pod 'BLTSwiftUIKit', '= 1.3.7'
  pod 'AvoidCrash', '~>2.5.2'
  pod 'CHTCollectionViewWaterfallLayout/ObjC', '= 0.9.10'
  pod 'JXPagingView/Paging', '= 2.1.2'
  pod 'JXSegmentedView', '1.2.7'
  pod 'MJRefresh'
  pod 'YYKit', '~> 1.0.9'
  pod 'Dollar'
  pod 'AFNetworking', '~> 4.0'
  pod 'TXLiteAVSDK_Player', :modular_headers => true
  pod 'SuperPlayer', :modular_headers => true
  pod 'BLTAlertEventQueue'
#  骨架屏
  pod 'SkeletonView'
#  转场动画
  pod 'Hero'
#  动画框架
  pod 'ViewAnimator'
#  动画框架
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
#  collectionView 卡片效果
  pod 'AnimatedCollectionViewLayout'
  pod 'FSPagerView', :git => 'https://github.com/WenchaoD/FSPagerView'
  
  pod 'IBPCollectionViewCompositionalLayout', '= 0.6.9'
  pod 'DiffableDataSources', '= 0.5.0'
  
#  检测卡顿的
  pod 'Watchdog'
  
  pod 'RxSwift', '= 6.2.0'
  pod 'RxCocoa', '= 6.2.0'
  pod 'RxDataSources', '= 5.0.0'
  pod 'Alamofire', '= 5.7.1'
  pod 'Moya', '= 15.0.0'
  pod 'Selene'
#  tabbar自定义的
  pod 'CYLTabBarController'
  #各种弹框样式的
  pod 'SwiftEntryKit', '= 2.0.0'
  #SwiftUI 滚动列表的
  pod 'DSScrollKit', '= 0.3.0'
  #加载 转圈动画的
  pod 'NVActivityIndicatorView', '= 5.1.1'
  #修改了源码   不能升级
  pod 'SwipeTableView', '= 0.2.6'
  pod 'WechatOpenSDK', '2.0.2'
#  pod 'charts', :git => 'https://github.com/danielgindi/Charts.git', :tag => '3.6.0
   #微信公众号悬浮框三方库
   pod 'JPSuspensionEntrance'
   #横幅播放音乐 点击全屏  收缩的
   pod  'LNPopupController'
   pod "SJVideoPlayer"
   #日期处理库
   pod 'SwiftDate', '6.3.1'




  target 'LBUIProjectTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LBUIProjectUITests' do
    # Pods for testing
  end

end


post_install do |installer|
  
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
#    config.build_settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = true
    end
  end
  
end
