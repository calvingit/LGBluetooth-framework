//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

/**
 *  温度单位
 */
typedef NS_ENUM(NSInteger, LGTempUnit) {
    /**
     *  摄氏度
     */
    LGTempUnitCelsius,
    /**
     *  华氏度
     */
    LGTempUnitFahrenheit
};


/**
 *  温度单位命令
 */
@interface LGTempUnitCmd : LGBaseCommand
///设置单位
- (instancetype)setUnit:(LGTempUnit)unit success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
///读取单位
- (instancetype)readUnitWithSuccess:(LGBlockWithInteger)success failure:(LGBlockWithError)failure;
@end
