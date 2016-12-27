/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XLsn0wAnimation : NSObject

/*! 
 
 Incompatible pointer types assigning to 'id<>' from 'Class'
 
 此问题是直接用+类方法去调用才会出现
 
 解决方法 创建一个单例 然后用-实例方法去调用就不会有警告

 */
+ (XLsn0wAnimation *)defaultXLsn0w;

#pragma mark - Custom Animation

/**
 *   @brief 快速构建一个你自定义的动画,有以下参数供你设置.
 *
 *   @note  调用系统预置Type需要在调用类引入下句
 *
 *          #import <QuartzCore/QuartzCore.h>
 *
 *   @param type                动画过渡类型
 *   @param subType             动画过渡方向(子类型)
 *   @param duration            动画持续时间
 *   @param timingFunction      动画定时函数属性
 *   @param theView             需要添加动画的view.
 *
 *
 */

- (void)showAnimationType:(NSString *)type
              withSubType:(NSString *)subType
                 duration:(CFTimeInterval)duration
           timingFunction:(NSString *)timingFunction
                     view:(UIView *)theView;

#pragma mark - Preset Animation

/**
 *  下面是一些常用的动画效果
 */

// reveal
- (void)animationRevealFromBottom:(UIView *)view;
- (void)animationRevealFromTop:(UIView *)view;
- (void)animationRevealFromLeft:(UIView *)view;
- (void)animationRevealFromRight:(UIView *)view;

// 渐隐渐消
- (void)animationEaseIn:(UIView *)view;
- (void)animationEaseOut:(UIView *)view;

// 翻转
- (void)animationFlipFromLeft:(UIView *)view;
- (void)animationFlipFromRigh:(UIView *)view;

// 翻页
- (void)animationCurlUp:(UIView *)view;
- (void)animationCurlDown:(UIView *)view;

// push
- (void)animationPushUp:(UIView *)view;
- (void)animationPushDown:(UIView *)view;
- (void)animationPushLeft:(UIView *)view;
- (void)animationPushRight:(UIView *)view;

// move
- (void)animationMoveUp:(UIView *)view duration:(CFTimeInterval)duration;
- (void)animationMoveDown:(UIView *)view duration:(CFTimeInterval)duration;
- (void)animationMoveLeft:(UIView *)view;
- (void)animationMoveRight:(UIView *)view;

// 旋转缩放

// 各种旋转缩放效果
- (void)animationRotateAndScaleEffects:(UIView *)view;

// 旋转同时缩小放大效果
- (void)animationRotateAndScaleDownUp:(UIView *)view;

#pragma mark - Private API

/**
 *  下面动画里用到的某些属性在当前API里是不合法的,但是也可以用.
 */

- (void)animationFlipFromTop:(UIView *)view;
- (void)animationFlipFromBottom:(UIView *)view;

- (void)animationCubeFromLeft:(UIView *)view;
- (void)animationCubeFromRight:(UIView *)view;
- (void)animationCubeFromTop:(UIView *)view;
- (void)animationCubeFromBottom:(UIView *)view;

- (void)animationSuckEffect:(UIView *)view;

- (void)animationRippleEffect:(UIView *)view;

- (void)animationCameraOpen:(UIView *)view;
- (void)animationCameraClose:(UIView *)view;

@end

