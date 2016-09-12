//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"
/**
 *  亮屏时间，单位为秒
 */
@interface LGScreenTimeCmd : LGBaseCommand
/**
 *  设置亮屏时间
 *
 *  @param time    亮屏时间
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)setScreenTime:(NSInteger)time success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
/**
 *  读取屏幕方向
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)readScreenTimeWithSuccess:(LGBlockWithInteger)success failure:(LGBlockWithError)failure;
@end
