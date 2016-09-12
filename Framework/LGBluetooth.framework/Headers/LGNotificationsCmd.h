//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGNotificationSettings;

typedef void(^LGNotificationsBlock)(LGNotificationSettings *settings);

/**
 * 推送通知等开关设置
 */
@interface LGNotificationsCmd : LGBaseCommand

///设置开关
- (instancetype)setNotifications:(LGNotificationSettings *)settings success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

///读取开关设置
- (instancetype)readNotificaitonSettingsWithSuccess:(LGNotificationsBlock)success failure:(LGBlockWithError)failure;

@end

/**
 *  通知等开关
 */
@interface LGNotificationSettings : NSObject

@property (nonatomic, assign) BOOL calling;///来电

@property (nonatomic, assign) BOOL missedCall;///未接来电

@property (nonatomic, assign) BOOL SMS;///短信

@property (nonatomic, assign) BOOL email;///邮件

@property (nonatomic, assign) BOOL social;///社交信息（微信、QQ、Facebook等）

@property (nonatomic, assign) BOOL calendar;///日历(如果开启，需要LGCalendarEventCmd同步日历事件)

@property (nonatomic, assign) BOOL powerSavingMode;///省电模式(开启之后部分功能会不震动)

@property (nonatomic, assign) BOOL antilost;///防丢(超过10m距离或蓝牙断开会震动)

@property (nonatomic, assign) BOOL heartRateAlarm;///心率报警(超过预设范围会震动)
@end
