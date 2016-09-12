//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"

/**
 *  返回设备上显示的验证码，NSString, 4个字符
 *  只适用于有显示屏的设备
 */
@interface LGPairingCodeCmd : LGBaseCommand

/// 设置回调
- (instancetype)readCodeWithSuccess:(LGBlockWithString)success failure:(LGBlockWithError)failure;
@end
