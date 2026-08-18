# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Build & Run

- **Open project**: `open LBUIProject.xcworkspace` (CocoaPods workspace, not .xcodeproj)
- **Build & run**: Cmd+R in Xcode using the `LBUIProject` scheme (debug config, iOS 14.0+)
- **Build IPA**: Scheme `build_test_ipa` (release config, for ad-hoc distribution)
- **Test**: Cmd+U runs `LBUIProjectTests` and `LBUIProjectUITests` targets via the scheme
- **CocoaPods**: `pod install` after Podfile changes (use `--repo-update` if new pods added)
- **Dependencies managed via** `Podfile` — ~50 pods including Masonry, SnapKit, Kingfisher, QMUIKit, RxSwift, Moya, YYKit, MJRefresh, MMKV, etc.

## Project Overview

Personal iOS demo/sandbox project exploring iOS features, third-party SDKs, and design patterns. Mixed ObjC + Swift, targets iOS 14.0+.

### Multi-Target Structure

| Target | Type | Notes |
|---|---|---|
| `LBUIProject` | Main app | ObjC + Swift mixed, primary target |
| `LBUIProjectHighIOSVersion` | Separate app target | Swift-only, with SceneDelegate, high iOS version features |
| `LBWidget` | Widget Extension | SwiftUI widget + Live Activity |
| `LBUIProjectTests` | Unit tests | ObjC |
| `LBUIProjectUITests` | UI tests | ObjC |
| `LBUIProjectHighIOSVersionTests` | Unit tests | Swift |
| `LBUIProjectHighIOSVersionUITests` | UI tests | Swift |

### Tab Architecture (TransparentTabBarController)

Root is `TransparentTabBarController` (Swift, custom UITabBarController in `LBCustomTabbarController.swift`):

| Tab | Controller | Language | Content |
|---|---|---|---|
| 首页 | `LBHomeViewController` | ObjC | UITableView listing ~40 demo entries (gesture, animation, GCD, KVO/KVC, cache, RxSwift, etc.) |
| 控件 | `LBSecondViewController` | Swift | UICollectionView grid listing UI component demos (calendar, image clip, drawer, IGListKit, etc.) |
| 三方库 | `LBThirdSDKController` | Swift | RxSwift-based UITableView listing third-party SDK demos (JXPaging, IJKPlayer, GPUImage, SwiftEntryKit, etc.) |
| 验证 | `LBVerifyViewController` | Swift | UICollectionView grid listing verification/experiment demos (Combine, async/await, Codable, PropertyWrapper, etc.) |
| SwiftUI | `LBSwiftUIHomeController` | Swift | UICollectionView grid listing SwiftUI demos (charts, ScrollKit, animations, Combine, mixed UIKit+SwiftUI) |

Navigation: `LBBaseNavigationController` — pushes hide tab bar, delegates status bar style to child, forwards rotation/orientation.

### Directory Layout

- **`LBUIProject/FirstTabbarVC/`** — 首页 tab entries (Chinese-named folders for each topic): 动画, KVC, KVO, GCD, 响应链, 转场动画, 链式调用, RxSwift, AI功能区, etc. ~40 subdirectories
- **`LBUIProject/SecondTabbar/`** — 控件 tab: Calendar, DrawImage, IGListKitDecoration, ImageClip
- **`LBUIProject/ThirdPartModule/`** — Third-party SDK demos
- **`LBUIProject/SwiftUIModule/`** — All SwiftUI demos: Combine, ChartView, Animation, MixSwiftUIView, Table, etc.
- **`LBUIProject/验证/`** — Verification/experiment pages: Combine, TaskAndAwait, Codable, PropertyWrapper, AIChat, MarkdownTable, etc. ~30 subdirectories
- **`LBUIProject/Category/`** — Extensions: UIControl, UIImage, NSString, UIColor, UIView, Array, Dictionary, NSObject
- **`LBUIProject/Util/`** — Utilities: LogUtil, CompressVideoUtil, FDFullscreenPopGesture, CustomQueue
- **`LBUIProject/Base/`** — `LBBaseCollectionViewController.swift` (reusable grid list base class with `LBListItemModel`)
- **`LBUIProject/APM/`** — Performance monitoring
- **`LBUIProject/LBHelper/`** — Misc helpers
- **`OCFsPage/`** — FSPagerView custom ObjC wrapper using UICollectionView

### Key Patterns & Conventions

- **Mixed language**: ObjC classes import Swift via `#import "LBUIProject-Swift.h"`. The bridging header is `LBUIProject-Bridging-Header.h`.
- **Base collection controller**: `LBBaseCollectionViewController` is used extensively for grid-list style controller pages. It uses `LBListItemModel` (title + vcClass) for routing.
- **Log prefix**: `LBLog` — all NSLog/print debug output uses this prefix for easy filtering.
- **Pod internal framework**: `BLTUIKitProject` / `BLTBasicUIKit` from private spec repo — provides BLT-prefixed UIKit extensions (`.blt.` namespace).
- **Custom Combine framework**: `LBCombineFramewrok` (typo intentional in code) — embedded framework in project.
- **Auto layout**: Mix of Masonry (ObjC) and SnapKit (Swift).
- **Resource images**: `pageView1`, `third_sdk`, `mine` etc. in Assets.xcassets.

### Environment

- Xcode 14+ (LastUpgradeVersion 1530 for some schemes, 1320 for others)
- iOS Deployment Target: 14.0
- CocoaPods with two sources: trunk + private `git@github.com:mushanlianshi/LBUIKitSpecRepo.git`
- Debug scheme sets env var `runEnvironment=pre`
