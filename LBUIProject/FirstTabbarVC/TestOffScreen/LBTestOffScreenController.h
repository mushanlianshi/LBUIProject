//
//  LBTestOffScreenController.h
//  LBUIProject
//
//  Created by liu bin on 2021/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//离屏渲染触发的条件
//1。前提是设置了圆角cornerRadius和clipToBounds
//2.mask设置了遮罩
//3.layer.shouldRasterize光栅化

//离屏渲染：当切圆角的时候有两个图层或以上，苹果无法一起切   只能一个一个图层处理，所以就会在离屏缓冲区进行处理  处理完在切换到当前缓冲区在屏幕内展示  导致离屏渲染 ，要切换缓冲区  浪费性能。
//图片需要一个单独的图层来处理，背景和边框在一个图层上展示(既一个layer)。两个控件得是两个图层（每个控件一个layer）
//比如1：只是一个图片设置clipToBounds，如果没有设置背景色或则边框的情况，是不会触发的。
//比如2：一个view不是（imageView，imageView可能设置了图片）如果没有子视图，设置clipToBounds，即使设置了背景色和边框，也不会触发离屏渲染的
//所以不是切圆角就会触发离屏渲染，主要看渲染的图层数是否大于1
//离屏渲染只是渲染的机制  我们也会主动使用的   比如layer 的mask做效果
@interface LBTestOffScreenController : UIViewController

@end

NS_ASSUME_NONNULL_END
