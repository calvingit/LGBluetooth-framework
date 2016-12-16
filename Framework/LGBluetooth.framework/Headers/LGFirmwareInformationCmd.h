//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"
/**
 *  固件信息回调
 *
 *  @param bindingStatus 绑定状态(忽略)
 *  @param batteryPower  设备电量,百分比
 *  @param version       软件版本
 */
typedef void(^LGFirmwareInformationBlock)(BOOL bindingStatus, NSInteger batteryPower, NSString *version);

/**
 *  获取固件信息
 */
@interface LGFirmwareInformationCmd : LGBaseCommand

- (instancetype)readFirmwareInformationWithSuccess:(LGFirmwareInformationBlock)success failure:(LGBlockWithError)failure;

@end
