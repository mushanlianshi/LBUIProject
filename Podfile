# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:mushanlianshi/LBUIKitSpecRepo.git'
source 'http://git.ethank.com.cn/liubin/xinlimeiprivaterepo.git'

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
  pod 'BLTBasicUIKit', '0.3.1'
#  pod 'BLTUIKitProject', :git => 'git@github.com:mushanlianshi/BLTUIKitProject.git', :tag => '= 1.9.3'
  pod 'BLTUIKitProject', '= 1.9.3'
  pod 'QMUIKit', '4.8.0'
  pod 'MBProgressHUD'
  pod 'MMKV'
#  pod 'SMSwiftBasicKit', '= 1.5.0'
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
  pod 'BLTAlertEventQueue', '1.1.7'
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
  pod 'UITableView+FDTemplateLayoutCell', '= 1.6'
  
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
   pod 'IGListKit', '5.0.0'
   pod 'HandyJSON', '5.0.2'
   pod 'TABAnimated'
   #弹框队列
   pod 'CLPopoverManager', '0.0.1'
   pod 'DateToolsSwift'
   pod 'SMSwiftBasicKit', '0.1.5'
   pod 'lottie-ios'
   pod 'BLTIconFont', :git => 'git@github.com:mushanlianshi/BLTIconFont.git'
   
   #滤镜
   pod 'GPUImage', '0.1.7'
   #textField等原生属性设置的
#   pod 'SwiftUIIntrospect', '1.3.0'
  #添加下拉刷新的
  pod "SwiftUIRefresh"


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
