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
//类开头是+开头

typedef NS_ENUM(NSInteger,ZGSizeType) {
    ZGSizeTypeOrigin = 2,   //原始数据，b
    ZGSizeTypeNormalized  //规格化后的数据
};

#import <CoreGraphics/CGBase.h>
typedef NS_ENUM(NSInteger,ZGBatteryState) {
    ZGBatteryStateUnknown,
    ZGBatteryStateUnplugged,    //未充电
    ZGBatteryStateCharging,   //正在充电
    ZGBatteryStateFull       //充满电
};

#import <CoreLocation/CoreLocation.h>
typedef void(^ChangeLocationBlock) (CLPlacemark *location,NSString *desc);

#import <CoreGraphics/CGBase.h>

@interface XLsn0wClassMethods : NSObject <CLLocationManagerDelegate>

+ (void)xlsn0w_adjustInterfaceOrientation:(UIInterfaceOrientation)orientation;
/**
 *  邮箱验证
 *
 *  @param email 邮箱
 *
 *  @return YES:正确  NO:失败
 */
+ (BOOL)checkForEmail:(NSString *)email;

/**
 *  手机号验证
 *
 *  @param phone 手机号
 *
 *  @return YES:正确  NO:失败
 */
+(BOOL)checkForMobilePhoneNo:(NSString *)mobilePhone;

/**
 *  电话号验证
 *
 *  @param phone 电话号
 *
 *  @return 结果
 */
+(BOOL)checkForPhoneNo:(NSString *)phone;

/**
 *  身份证号验证(15位 或 18位)
 *
 *  @param idCard 身份证号
 *
 *  @return YES:正确  NO:失败
 */
+(BOOL)checkForIdCard:(NSString *)idCard;

/**
 *  密码验证
 *
 *  @param shortest 最短长度
 *  @param longest  最长长度
 *  @param pwd      密码
 *
 *  @return 结果
 */
//+(BOOL)checkForPasswordWithShortest:(NSInteger)shortest longest:(NSInteger)longest password:(NSString *)pwd;


/**
 *  由数字和26个英文字母组成的字符串
 *
 *  @param idCard 数据
 *
 *  @return 结果
 */
+ (BOOL)checkForNumberAndCase:(NSString *)data;


/**
 *  校验只能输入26位小写字母
 *
 *  @param 数据
 *
 *  @return 结果
 */
+ (BOOL)checkForLowerCase:(NSString *)data;

/**
 *  校验只能输入26位大写字母
 *
 *  @param data 数据
 *
 *  @return 结果
 */
+ (BOOL)checkForUpperCase:(NSString *)data;

/**
 *  校验只能输入由26个小写英文字母组成的字符串
 *
 *  @param data 字符串
 *
 *  @return 结果
 */
+ (BOOL)checkForLowerAndUpperCase:(NSString *)data;

/**
 *  是否含有特殊字符(%&’,;=?$\等)
 *
 *  @param data 数据
 *
 *  @return 结果
 */
+ (BOOL)checkForSpecialChar:(NSString *)data;


/**
 *  校验只能输入数字
 *
 *  @param number 数字
 *
 *  @return 结果
 */
+ (BOOL)checkForNumber:(NSString *)number;

/**
 *  校验只能输入n位的数字
 *
 *  @param length n位
 *  @param number 数字
 *
 *  @return 结果
 */
+ (BOOL)checkForNumberWithLength:(NSString *)length number:(NSString *)number;

+ (void)initNavigationControllerWithRootViewController:(UIViewController *)viewController
                                       tabBarItemTitle:(NSString *)title
                                   tabBarItemImageName:(NSString *)imageName
                           tabBarItemSelectedImageName:(NSString *)selectedImageName currentSelf:(UIViewController *)currentSelf;


+ (void)xl_setURLCache;

/************************这里是用来获取设备的一些信*****************************************************/

/**
 *  是否支持多任务
 *
 *  @return YES表示支持，NO表示不支持
 */
- (BOOL)multitaskingSupported;

/**
 *  得到当前用的什么手机，iPhon5s? iPhone6s ....
 *
 *  @return 手机类型名称
 */
- (NSString *)getCurrentDevicePhoneType;
/**
 *  得到当前设备独一标识符
 *
 *  @return 例如：0996E3AC-8800-4961-A3BF-5D49299C96E7
 */
- (NSString *)getUUID;
/**
 *  得到当前设备类型 ：iPhone / iPad
 *
 *  @return iPhone / iPad
 */
- (NSString *)getDeviceType;
/**
 *  得到当前的手机名称，关于本机里面的名称
 *
 *  @return 手机名称
 */
- (NSString *)getCurrentDeviceName;
/**
 *  得到当前系统名称
 *
 *  @return 系统名称
 */
- (NSString *)getSystemName;
/**
 *  得到当前系统版本
 *
 *  @return 版本.例如：9.3.4,以及最新的10
 */
- (NSString *)getSystemVersion;
/**
 *  获取当前设置XNU内核版本号
 *
 *  @return 返回当前XNU内核版本号
 */
- (NSString *)getKernelVersion;
/**
 *  得到构建描述
 *
 *  @return 得到内核描述信息
 */
- (NSString *)getDarwinBuildDescription;
/**
 *  得到硬件类型
 *
 *  @return 硬件类型,iPhone8,1,iPhone5.1等等
 */
- (NSString *)getHardWardType;
/**
 *  得到当前网络节点名称
 *
 *  @return 当前节点名称
 */
- (NSString *)getNetWordNodeName;
/**
 *  得到当前操作系统名称
 *
 *  @return 内核操作系统名称
 */
- (NSString *)getOSName;

/**
 *  得到当前设备的核数
 *
 *  @return 核数
 */
- (NSInteger)getNuclearCount;
/**
 *  得到当前设备活跃的核数
 *
 *  @return 核数
 */
- (NSInteger)getActiveNuclearCount;

/**
 *  得到当前磁盘总大小
 *
 *  @param type 大小类型：ZGSizeTypeOrigin是原始大小，没有经过转换，单位为B；ZGSizeTypeNormalized是规格化后的大小
 *
 *  @return 返回大小，可能有差距，但是相差不大
 */
- (NSString *)getDiskTotalSizeBySizeType:(ZGSizeType)type;

/**
 *  得到当前磁盘空闲内存大小
 *
 *  @param type type 大小类型：ZGSizeTypeOrigin是原始大小，没有经过转换，单位为B；ZGSizeTypeNormalized是规格化后的
 *
 *  @return 返回大小，可能有差距，但是相差不大
 */
- (NSString *)getDiskFreeSizeBySizeType:(ZGSizeType)type;
/**
 *  得到当前磁盘已经使用的大小
 *
 *  @param type type 大小类型：ZGSizeTypeOrigin是原始大小，没有经过转换，单位为B；ZGSizeTypeNormalized是规格化后的
 *
 *  @return 返回大小，可能有差距，但是相差不大
 */
- (NSString *)getDiskUsedSizeBySizeType:(ZGSizeType)type;

/**
 *  得到当前物理内存总大小，指通过物理内存而获得的内存空间大小
 *
 *  @param type 大小类型：ZGSizeTypeOrigin是原始大小，没有经过转换，单位为B；ZGSizeTypeNormalized是规格化后的大小
 *
 *  @return 返回大小
 */
- (NSString *)getMemoryTotalSizeBySizeType:(ZGSizeType)type;

/**
 *  得到当前物理内存空闲内存大小 Unimplemented
 *
 *  @param type type 大小类型：ZGSizeTypeOrigin是原始大小，没有经过转换，单位为B；ZGSizeTypeNormalized是规格化后的
 *
 *  @return 返回大小，可能有差距，但是相差不大
 */
- (NSString *)getMemoryFreeSizeBySizeType:(ZGSizeType)type;
/**
 *  得到当前内存已经使用的大小 Unimplemented
 *
 *  @param type type 大小类型：ZGSizeTypeOrigin是原始大小，没有经过转换，单位为B；ZGSizeTypeNormalized是规格化后的
 *
 *  @return 返回大小，可能有差距，但是相差不大
 */
- (NSString *)getMemoryUsedSizeBySizeType:(ZGSizeType)type;

/**
 *  当前电池量
 *
 *  @return 0-1
 */
- (CGFloat)currentBatteryLevel;
/**
 *  电池状态
 *
 *  @return 正在充电、未充电、充满电
 */
- (ZGBatteryState)batteryState;
/**
 *  电池是否允许监控
 *
 *  @return YES表示能够监控，NO表示不能够监控
 */
- (BOOL)isAllowMonitorBattery;

/**
 *  是否越狱
 *
 *  @return YES表示已经越狱，NO表示没有越狱
 */
+ (BOOL)isJailBreak;

/**
 *  block回调
 */
@property (nonatomic,copy)ChangeLocationBlock blockLocation;

/**
 *  得到设备当前的位置,block回调里面已经包含了CLPlacemark里面包含了你需要的信息，需要自取
 *  详细可以参考CLPlacemark类属性
 *
 *  @return CLLocation
 */
- (void)getCurrentLocation:(ChangeLocationBlock)block;

/**
 *  获取当前项目信息
 */

/**
 *  得到当前项目版本
 *
 *  @return 当前版本
 */
- (NSString *)getProjectVersion;

/**
 *  得到当前项目构建版本号
 *
 *  @return 当前构建版本
 */
- (NSString *)getProjectBuildVersion;



/**
 *  得到当前项目名称
 *
 *  @return 当前名称
 */
- (NSString *)getProjectName;

/**
 *  得到当前屏幕宽度
 *
 *  @return 宽度值
 */
- (CGFloat)getCurrentScreenWith;
/**
 *  得到当前屏幕高度
 *
 *  @return 高度值
 */
- (CGFloat)getCurrentScreenHeight;

/**
 *  得到屏幕亮度
 *
 *  @return 0-1
 */
- (CGFloat)getScreenBrightness;
/**
 *  屏幕分辨率
 *
 *  @return
 */
- (NSString *)screenResolution;
/**
 *  得到当前屏幕dpi
 *
 *  @return return value description
 */
- (CGFloat)getScreenDpi;

@end

