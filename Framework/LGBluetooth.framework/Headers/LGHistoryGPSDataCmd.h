//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//


#import "LGBaseCommand.h"

@class LGGPSData;

typedef void(^LGHistoryGPSDataBlock)(NSArray<LGGPSData *> *datas);

@interface LGHistoryGPSDataCmd : LGBaseCommand
- (instancetype)readDataWithSuccess:(LGHistoryGPSDataBlock)success failure:(LGBlockWithError)failure;
@end

/**
 *  gps数据状态
 */
typedef NS_ENUM(NSInteger, LGGPSDataState) {
    /**
     *  开始
     */
    LGGPSDataStateStarting = 1,
    /**
     *  行走中
     */
    LGGPSDataStateRunning = 2,
    /**
     *  结束
     */
    LGGPSDataStateEnding = 3,
};

/**
 *  运动类型
 */
typedef NS_ENUM(NSInteger, LGSportType) {
    /**
     *  骑行
     */
    LGSportTypeRiding = 1,
    /**
     *  跑步
     */
    LGSportTypeRunning = 2,
};

/**
 *  GPS数据
 */
@interface LGGPSData : NSObject
///数据状态
@property (nonatomic, assign) LGGPSDataState state;
///运动类型
@property (nonatomic, assign) LGSportType    sportType;
///时间
@property (nonatomic, assign) NSDate         *date;
///纬度
@property (nonatomic, assign) double         latitude;
///经度
@property (nonatomic, assign) double         longitude;
///数据索引 (画轨迹的时候需要用到排序)
@property (nonatomic, assign) NSInteger      index;
@end
