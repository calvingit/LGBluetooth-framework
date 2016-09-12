//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"
/**
 *  距离单位
 */
typedef NS_ENUM(NSInteger, LGDistanceUnit) {
    /**
     *  千米
     */
    LGDistanceUnitKM,
    /**
     *  英里
     */
    LGDistanceUnitMI
};


/**
 *  距离单位
 */
@interface LGDistanceUnitCmd : LGBaseCommand
///设置单位
- (instancetype)setUnit:(LGDistanceUnit)unit success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
///读取单位
- (instancetype)readUnitWithSuccess:(LGBlockWithInteger)success failure:(LGBlockWithError)failure;
@end
