//
//  XLsn0wInstanceMethods.h
//  XLsn0wKit
//
//  Created by XLsn0w on 2016/10/10.
//  Copyright © 2016年 XLsn0w. All rights reserved.
//

#import <Foundation/Foundation.h>

//实例方法是-开头

@interface XLsn0wInstanceMethods : NSObject

@end

/**************************************************************************************************/
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface CIImage (XLsn0wUtility)

/** 将CIImage转换成UIImage */
- (UIImage *)xlsn0w_createNonInterpolatedWithSize:(CGFloat)size;

@end

/**************************************************************************************************/
