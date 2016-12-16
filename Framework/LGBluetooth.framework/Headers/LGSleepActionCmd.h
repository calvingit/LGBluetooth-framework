//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseSettingCommand.h"
/**
 *  睡眠动作
 */
typedef NS_ENUM(NSInteger, LGSleepAction){
    /**
     *  立即进入睡眠
     */
    LGSleepActionEnter = 0x02,
    /**
     *  立即退出睡眠
     */
    LGSleepActionQuit = 0x01,
};

/**
 *  关闭了预设睡眠的时候，可以手动进入睡眠
 */
@interface LGSleepActionCmd : LGBaseSettingCommand

@property (nonatomic, assign) LGSleepAction action;

@end
