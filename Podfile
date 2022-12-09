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
  pod 'BLTSwiftUIKit', '= 1.2.1'
  pod 'AvoidCrash', '~>2.5.2'
  pod 'CHTCollectionViewWaterfallLayout/ObjC', '= 0.9.10'
  pod 'JXPagingView/Pager'
  pod 'JXCategoryView'
  pod 'MJRefresh'
  pod 'YYKit', '~> 1.0.9'
  pod 'Dollar'
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
  
#  检测卡顿的
  pod 'Watchdog'
  
  pod 'RxSwift', '= 6.2.0'
  pod 'RxCocoa', '= 6.2.0'
#  tabbar自定义的
  pod 'CYLTabBarController'
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
