//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"
@class LGHeartRateData;

/**
 *  心率回调
 *
 *  @param hrValue 心率值
 */
typedef void(^LGHistoryHeartRateDataBlock)(NSArray<LGHeartRateData *> *datas);

/**
 *  读取心率的历史数据
 */
@interface LGHistoryHeartRateDataCmd : LGBaseCommand

- (instancetype)readDataWithSuccess:(LGHistoryHeartRateDataBlock)success failure:(LGBlockWithError)failure;

@end

/**
 *  心率数据
 */
@interface LGHeartRateData : NSObject
///心率值
@property (nonatomic, assign)  NSInteger value;
///时间
@property (nonatomic, strong)  NSDate *date;
@end