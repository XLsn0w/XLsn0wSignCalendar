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

#import "XLsn0wClassMethods.h"

#import "XLsn0wKit.h"

#import <sys/utsname.h>
#import <UIkit/UIDevice.h>

#import <CoreGraphics/CGBase.h>
#import <sys/mount.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

#import <UIkit/UIApplication.h>
#include <stdlib.h>

#import <UIkit/UIScreen.h>

#define isIOS(version) ([[UIDevice currentDevice].systemVersion floatValue] >= version)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000 //假如固件是iOS10 控制器self就遵守CAAnimationDelegate协议
@interface XLsn0wClassMethods () <CAAnimationDelegate>
#else //固件低于iOS 10, 否则就不遵守CAAnimationDelegate协议 无需填写
@interface XLsn0wClassMethods ()
#endif

@property (nonatomic, strong) NSDictionary *utsNameDic;
@property (nonatomic, strong) NSProcessInfo *processInfo;
@property (nonatomic, strong) UIDevice *device;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *projectInfoDic;
@property (nonatomic,strong)UIScreen *screen;

@end

static NSString * const kMachine = @"machine";
static NSString * const kNodeName = @"nodename";
static NSString * const kRelease = @"release";
static NSString * const kSysName = @"sysname";
static NSString * const kVersion = @"version";

@implementation XLsn0wClassMethods

+ (void)xlsn0w_adjustInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - 邮箱校验
+ (BOOL)checkForEmail:(NSString *)email {
    
    NSString *regEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self baseCheckForRegEx:regEx data:email];
}

#pragma mark - 验证手机号
+ (BOOL)checkForMobilePhoneNo:(NSString *)mobilePhone {
    
    NSString *regEx = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    return [self baseCheckForRegEx:regEx data:mobilePhone];
}

#pragma mark - 验证电话号
+ (BOOL)checkForPhoneNo:(NSString *)phone {
    NSString *regEx = @"^(\\d{3,4}-)\\d{7,8}$";
    return [self baseCheckForRegEx:regEx data:phone];
}

#pragma mark - 身份证号验证
+ (BOOL)checkForIdCard:(NSString *)idCard {
    
    NSString *regEx = @"(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)";
    return [self baseCheckForRegEx:regEx data:idCard];
}
#pragma mark - 密码校验
//+ (BOOL)checkForPasswordWithShortest:(NSInteger)shortest longest:(NSInteger)longest password:(NSString *)pwd {
//    NSString *regEx =[NSString stringWithFormat:@"^[a-zA-Z0-9]{%ld,%ld}+$", shortest, longest];
//    return [self baseCheckForRegEx:regEx data:pwd];
//}

//----------------------------------------------------------------------

#pragma mark - 由数字和26个英文字母组成的字符串
+ (BOOL)checkForNumberAndCase:(NSString *)data {
    NSString *regEx = @"^[A-Za-z0-9]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 小写字母
+ (BOOL)checkForLowerCase:(NSString *)data {
    NSString *regEx = @"^[a-z]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 大写字母
+ (BOOL)checkForUpperCase:(NSString *)data {
    NSString *regEx = @"^[A-Z]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 26位英文字母
+ (BOOL)checkForLowerAndUpperCase:(NSString *)data {
    NSString *regEx = @"^[A-Za-z]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 特殊字符
+ (BOOL)checkForSpecialChar:(NSString *)data {
    NSString *regEx = @"[^%&',;=?$\x22]+";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 只能输入数字
+ (BOOL)checkForNumber:(NSString *)number {
    NSString *regEx = @"^[0-9]*$";
    return [self baseCheckForRegEx:regEx data:number];
}

#pragma mark - 校验只能输入n位的数字
+ (BOOL)checkForNumberWithLength:(NSString *)length number:(NSString *)number {
    NSString *regEx = [NSString stringWithFormat:@"^\\d{%@}$", length];
    return [self baseCheckForRegEx:regEx data:number];
}


#pragma mark - 私有方法
/**
 *  基本的验证方法
 *
 *  @param regEx 校验格式
 *  @param data  要校验的数据
 *
 *  @return YES:成功 NO:失败
 */
+(BOOL)baseCheckForRegEx:(NSString *)regEx data:(NSString *)data{
    
    NSPredicate *card = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    if (([card evaluateWithObject:data])) {
        return YES;
    }
    return NO;
}

+ (void)initNavigationControllerWithRootViewController:(UIViewController *)viewController
                                       tabBarItemTitle:(NSString *)title
                                   tabBarItemImageName:(NSString *)imageName
                           tabBarItemSelectedImageName:(NSString *)selectedImageName
                                           currentSelf:(UIViewController *)currentSelf {
    XLsn0wNavigationController *childNC = [[XLsn0wNavigationController alloc] initWithRootViewController:viewController];
    childNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [currentSelf addChildViewController:childNC];
}

+ (void)xl_setURLCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

//-------
- (NSInteger)getNuclearCount {
    return self.processInfo.processorCount;
}
- (NSInteger)getActiveNuclearCount {
    return self.processInfo.activeProcessorCount;
}
//--------
- (NSString *)getKernelVersion {
    return self.utsNameDic[kRelease];
}

- (NSString *)getDarwinBuildDescription {
    return self.utsNameDic[kVersion];
}

- (NSString *)getOSName {
    return self.utsNameDic[kSysName];
}

- (NSString *)getHardWardType {
    return self.utsNameDic[kMachine];
}

- (NSString *)getNetWordNodeName {
    return self.utsNameDic[kNodeName];
}
//---------9.3.4
- (NSString *)getSystemName {
    return self.device.systemName;
}
- (NSString *)getSystemVersion {
    return self.device.systemVersion;
}
- (BOOL)multitaskingSupported {
    return self.device.multitaskingSupported;
}
- (NSString *)getUUID {
    return [self.device.identifierForVendor UUIDString];
}
- (NSString *)getCurrentDeviceName {
    return self.device.name;
}
- (NSString *)getDeviceType {
    return self.device.model;
}
- (NSString *)getCurrentDevicePhoneType {
    NSString *platform = self.utsNameDic[kMachine];;
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
    
}

#pragma mark - Lazy Load
- (UIDevice *)device {
    if (!_device) {
        _device = [UIDevice currentDevice];
    }
    return _device;
}
- (NSDictionary *)utsNameDic {
    if (!_utsNameDic) {
        struct utsname systemInfo;
        uname(&systemInfo);
        _utsNameDic = @{kSysName:[NSString stringWithCString:systemInfo.sysname encoding:NSUTF8StringEncoding],kNodeName:[NSString stringWithCString:systemInfo.nodename encoding:NSUTF8StringEncoding],kRelease:[NSString stringWithCString:systemInfo.release encoding:NSUTF8StringEncoding],kVersion:[NSString stringWithCString:systemInfo.version encoding:NSUTF8StringEncoding],kMachine:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]};
    }
    return _utsNameDic;
}
- (NSProcessInfo *)processInfo {
    if (!_processInfo) {
        _processInfo = [NSProcessInfo processInfo];
    }
    return _processInfo;
}

//可用磁盘容量
- (NSString *)getDiskFreeSizeBySizeType:(ZGSizeType)type {
    if (type == ZGSizeTypeOrigin) {
        return [NSString stringWithFormat:@"%lld",[self p_getDiskFreeSize]];
    }else {
        return [self p_getSizeFromString:[self p_getDiskFreeSize]];
    }
    return nil;
}
//已用磁盘容量
- (NSString *)getDiskUsedSizeBySizeType:(ZGSizeType)type {
    if (type == ZGSizeTypeOrigin) {
        return [NSString stringWithFormat:@"%lld",[self p_getDiskTotalSize]-[self p_getDiskFreeSize]];
    }else {
        return [self p_getSizeFromString:([self p_getDiskTotalSize]-[self p_getDiskFreeSize])];
    }
    
}
//总磁盘容量
- (NSString *)getDiskTotalSizeBySizeType:(ZGSizeType)type {
    if (type == ZGSizeTypeOrigin) {
        return [NSString stringWithFormat:@"%lld",[self p_getDiskTotalSize]];
    }else {
        return [self p_getSizeFromString:[self p_getDiskTotalSize]];
    }
}
- (NSString *)getMemoryFreeSizeBySizeType:(ZGSizeType)type {
    return nil;
}
- (NSString *)getMemoryUsedSizeBySizeType:(ZGSizeType)type {
    return nil;
}
//物理内存大小
- (NSString *)getMemoryTotalSizeBySizeType:(ZGSizeType)type {
    if (type == ZGSizeTypeOrigin) {
        return [NSString stringWithFormat:@"%llu",self.processInfo.physicalMemory];
    }else {
        return [self p_getSizeFromString:self.processInfo.physicalMemory];
    }
    
}
#pragma mark - private method
//总磁盘大小
- (long long)p_getDiskTotalSize {
    struct statfs buf;
    unsigned long long totalSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        totalSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return totalSpace;
}
//总磁盘大小
- (long long)p_getDiskUsedSize {
    struct statfs buf;
    unsigned long long totalSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        totalSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return totalSpace;
}

//可用磁盘大小
- (long long)p_getDiskFreeSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}
/**
 *  得到规格化的存储大小
 *
 *  @param size 原始大小
 *
 *  @return 规格化存储大小
 */
- (NSString *)p_getSizeFromString:(long long)size {
    if (size>1024*1024*1024) {
        return [NSString stringWithFormat:@"%.1fGB",size/1024.f/1024.f/1024.f];   //大于1G转化成G单位字符串
    }
    if (size<1024*1024*1024 && size>1024*1024) {
        return [NSString stringWithFormat:@"%.1fMB",size/1024.f/1024.f];   //转成M单位
    }
    if (size>1024 && size<1024*1024) {
        return [NSString stringWithFormat:@"%.1fkB",size/1024.f]; //转成K单位
    }else {
        return [NSString stringWithFormat:@"%.1lldB",size];   //转成B单位
    }
    
}

- (ZGBatteryState)batteryState {
    switch (self.device.batteryState) {
        case UIDeviceBatteryStateFull:
            return ZGBatteryStateFull;
            break;
        case UIDeviceBatteryStateUnknown:
            return ZGBatteryStateUnknown;
            break;
        case UIDeviceBatteryStateCharging:
            return ZGBatteryStateCharging;
            break;
        case UIDeviceBatteryStateUnplugged:
            return ZGBatteryStateUnplugged;
            break;
        default:
            return ZGBatteryStateUnknown;
            break;
    }
}
- (CGFloat)currentBatteryLevel {
    return self.device.batteryLevel;
}
- (BOOL)isAllowMonitorBattery {
    return self.device.isBatteryMonitoringEnabled;
}

//这里用多个判断方式判断，确保判断更加准确
+ (BOOL)isJailBreak {
    return [self p_judgeByOpenAppFolder] || [self p_judgeByOpenUrl] || [self p_judgeByFolderExists] || [self p_judgeByReadDYLD_INSERT_LIBRARIES];
}



#pragma mark - private method
+ (BOOL)p_judgeByReadDYLD_INSERT_LIBRARIES {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env) {
        return YES;
    }
    return NO;
}
//通过能否打开软件安装文件夹判断
+ (BOOL)p_judgeByOpenAppFolder {
    NSError *error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSRange rang = [path rangeOfString:@"Application/"];
    NSString *appPath = [path substringToIndex:rang.location+ rang.length];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPath error:&error];
        if (arr && [arr count]!=0) {
            return YES;
        }else {
            return NO;
        }
        
        return YES;
    }
    return NO;
}
//通过能否打开cydia：//来判断，YES说明可以打开，就是越狱的，NO表示不可以打开
+ (BOOL)p_judgeByOpenUrl {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    return NO;
}


//通过文件夹判断，如果boo为YES说明有以下的一些文件夹，则说明已经越狱
+ (BOOL)p_judgeByFolderExists {
    __block BOOL boo = NO;
    NSArray *arr = @[@"/Applications/Cydia.app",@"/Library/MobileSubstrate/MobileSubstrate.dylib",@"/bin/bash",@"/usr/sbin/sshd",@"/etc/apt"];
    [arr enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:obj]) {
            boo = YES;
            *stop = YES;
        }
    }];
    return boo;
}

- (void)getCurrentLocation:(ChangeLocationBlock)block {
    self.blockLocation = block;
    if (![CLLocationManager locationServicesEnabled]) {
        if (self.blockLocation) {
            self.blockLocation(nil,@"请先开启定位功能");
        }
        return;
    }
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.delegate = self;
        CLLocationDistance distance  = 1.0;
        self.locationManager.distanceFilter = distance;  //最小的告诉位置更新的距离,单位是m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
        
    }else{
        self.locationManager.delegate = self;
        CLLocationDistance distance  = 500.0;
        self.locationManager.distanceFilter = distance;  //最小的告诉位置更新的距离,单位是m
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
    }
    
}
#pragma mark - lazy load
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];  //创建一个位置管理器
    }
    return _locationManager;
}
#pragma mark - CLLocationManageDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count>0) {
            CLPlacemark *placeMark = placemarks[0];
            if (self.blockLocation) {
                self.blockLocation(placeMark,@"定位成功");
            }
        }
    }];
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (self.blockLocation) {
        self.blockLocation(nil,@"方向改变");
    }
}


- (NSString *)getProjectName {
    return self.projectInfoDic[@"CFBundleName"];
}
- (NSString *)getProjectBuildVersion {
    return self.projectInfoDic[@"CFBundleVersion"];
}
- (NSString *)getProjectVersion {
    return self.projectInfoDic[@"CFBundleShortVersionString"];
}


#pragma mark - Lazy load
- (NSDictionary *)projectInfoDic {
    if (!_projectInfoDic) {
        _projectInfoDic = [[NSBundle mainBundle] infoDictionary];
    }
    return _projectInfoDic;
}

#pragma mark - method
- (CGFloat)getCurrentScreenWith {
    return self.screen.bounds.size.width;
}
- (CGFloat)getCurrentScreenHeight {
    return self.screen.bounds.size.height;
}
- (CGFloat)getScreenBrightness {
    return self.screen.brightness;
}
- (NSString *)screenResolution {
    return [NSString stringWithFormat:@"%.0f_%.0f",self.screen.scale*self.screen.bounds.size.height,self.screen.scale*self.screen.bounds.size.width];
}
/**
 *  获取dpi
 *
 *  @return dpi的值,参考：http://stackoverflow.com/questions/3860305/get-ppi-of-iphone-ipad-ipod-touch-at-runtime
 */
- (CGFloat)getScreenDpi {
    float scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 132*scale;
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 163*scale;
    }else {
        return 160*scale;
    }
    
}
#pragma mark - Lazy Load
- (UIScreen *)screen {
    if (!_screen) {
        _screen = [UIScreen mainScreen];
    }
    return _screen;
}

@end

