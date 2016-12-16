//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

/**
 *  回调Block
 *
 *  @param steps    步数
 *  @param calories 卡路里(小卡单位)
 */
typedef void(^LGCurrentSportDataBlock)(NSInteger steps, NSInteger calories);

/**
 *  获取当前运动数据（步数和卡路里），距离需要另行计算
 */
@interface LGCurrentSportDataCmd : LGBaseCommand

- (instancetype)readCurrentSportDataWithSuccess:(LGCurrentSportDataBlock)success failure:(LGBlockWithError)failure;
@end

