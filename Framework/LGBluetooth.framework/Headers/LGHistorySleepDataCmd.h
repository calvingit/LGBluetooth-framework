//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//


#import "LGBaseCommand.h"

@class LGSleepDetailData;
@class LGSleepData;

typedef void(^LGHistorySleepDataBlock)(NSArray<LGSleepData *> *datas);

/**
 *  读取睡眠的历史数据
 */
@interface LGHistorySleepDataCmd : LGBaseCommand
- (instancetype)readDataWithSuccess:(LGHistorySleepDataBlock)success failure:(LGBlockWithError)failure;
@end

/**
 *  睡眠数据
 */
@interface LGSleepData : NSObject
///睡眠开始日期
@property (nonatomic, strong) NSDate            *startDate;
///睡眠结束日期
@property (nonatomic, strong) NSDate            *endDate;
///深睡时间
@property (nonatomic, assign) NSInteger         deepSleepMinutes;
///浅睡时间
@property (nonatomic, assign) NSInteger         lightSleepMinutes;
///清醒时间
@property (nonatomic, assign) NSInteger         awakeMinutes;
///清醒次数
@property (nonatomic, assign) NSInteger         awakeCount;
///详细数据
@property (nonatomic, strong) NSArray<LGSleepDetailData *> *details;
@end

/**
 *  睡眠状态，一段完整的睡眠具有唯一的开始和结束，中间的状态是深睡、浅睡、清醒
 */
typedef NS_ENUM(NSInteger, LGSleepState) {
    /**
     *  开始
     */
    LGSleepStateStart = 16,
    /**
     *  深睡
     */
    LGSleepStateDeep  = 0,
    /**
     *  浅睡
     */
    LGSleepStateLight = 1,
    /**
     *  清醒
     */
    LGSleepStateAwake = 2,
    /**
     *  结束
     */
    LGSleepStateEnd   = 17,
};

/**
 *  睡眠详细数据
 */
@interface LGSleepDetailData : NSObject
/**
 *  对于LGSleepStateStart来说是开始时间，其它是结束时间
 */
@property (nonatomic, strong) NSDate *date;///时间
@property (nonatomic, assign) NSInteger minutes;///分钟数
@property (nonatomic, assign) LGSleepState state;///状态
@end
