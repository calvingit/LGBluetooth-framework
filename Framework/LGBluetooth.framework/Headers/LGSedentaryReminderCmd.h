//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGSedentaryReminder;

typedef void(^LGSedentaryReminderBlock)(LGSedentaryReminder *reminder);

/**
 *  久坐提醒命令，
 */
@interface LGSedentaryReminderCmd : LGBaseCommand

///设置
- (instancetype)setReminder:(LGSedentaryReminder *)reminder success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
///读取
- (instancetype)readReminderWithSuccess:(LGSedentaryReminderBlock)success failure:(LGBlockWithError)failure;

@end

/**
 *  久坐提醒，在一天的beginTime到endTime之间，每隔interval分钟检测一下运动量，如果不够validSteps，手环将震动提醒
 */
@interface LGSedentaryReminder : NSObject
@property (nonatomic, assign) BOOL      status;      //开关状态
@property (nonatomic, copy  ) NSString  *beginTime;  //开始时间,格式为"HH:mm",比如"09:30"
@property (nonatomic, copy  ) NSString  *endTime;    //结束时间,格式为"HH:mm",比如"23:10"
@property (nonatomic, assign) NSInteger interval;    //间隔时长,单位为分钟
@property (nonatomic, assign) NSInteger weekPeriod;  //周期，LGWeekPeriod
@property (nonatomic, assign) NSInteger validSteps;  //有效步数,运动量大于有效步数才算运动，否则算坐着，默认50
@end
