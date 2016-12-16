//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseSettingCommand.h"
/**
 *  音量操作
 */
typedef NS_ENUM(NSInteger, LGVolumeAction) {
    /**
     *  加大音量
     */
    LGVolumeUpAction   = 0x06,
    /**
     *  降低音量
     */
    LGVolumeDownAction = 0x07,
};

/**
 *  音量设置操作
 *  注意：只适用于YTB003等带有通话功能的手环
 */
@interface LGVolumeSettingCmd : LGBaseSettingCommand
///音量操作
@property (nonatomic, assign) LGVolumeAction action;
@end
