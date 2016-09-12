//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"

/**
 *  屏幕方向
 */
typedef NS_ENUM(NSInteger, LGOrientation){
    /// 横屏
    LGOrientationH,
    /// 竖屏
    LGOrientationV,
};

/**
 *  屏幕方向命令
 */
@interface LGScreenOrientationCmd : LGBaseCommand
/**
 *  设置屏幕方向
 *
 *  @param orientation 方向
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)setOrientation:(LGOrientation)orientation success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
/**
 *  读取屏幕方向
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)readOrientationWithSuccess:(LGBlockWithInteger)success failure:(LGBlockWithError)failure;
@end
