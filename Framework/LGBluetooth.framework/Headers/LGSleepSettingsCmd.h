//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGSleepSettings;

typedef void(^LGSleepSettingsBlock)(LGSleepSettings *sleepTime);

/**
 *  预设睡眠时间
 */
@interface LGSleepSettingsCmd : LGBaseCommand

- (instancetype)setSleepTime:(LGSleepSettings *)sleepTime success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
- (instancetype)readSleepTimeWithSuccess:(LGSleepSettingsBlock)success failure:(LGBlockWithError)failure;
@end

/**
 *  睡眠时间
 */
@interface LGSleepSettings : NSObject
@property (nonatomic, assign) BOOL status;       //开关状态，YES:打开, NO:关闭。如果是关闭的，sleepTime和wakeupTime会被忽略，都是"00:00"
@property (nonatomic, copy) NSString *sleepTime; //睡觉时间, 格式为"HH:mm", 如"22:30"
@property (nonatomic, copy) NSString *wakeupTime;//醒来时间, 格式为"HH:mm", 如"08:00"
@end
