//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#ifndef LGCommonHeader_h
#define LGCommonHeader_h
#import <Foundation/Foundation.h>

/**
 *  默认服务ID，一般的命令操作
 */
FOUNDATION_EXPORT NSString * const kDefaultServiceUUID;

/**
 *  特殊服务ID，用于固件升级。进入升级模式之后搜索包含这个服务的设备。
 */
FOUNDATION_EXPORT NSString * const kDFUServiceUUID;


#pragma mark - 枚举类型

/**
 *  相机控制动作
 */
typedef NS_ENUM(NSInteger, LGCameraAction) {
    /**
     *  拍照
     */
    LGCameraActionTakePicture = 0x00,
    /**
     *  关闭相机
     */
    LGCameraActionEnd =0x01,
    /**
     *  切换前置摄像头
     */
    LGCameraActionSwitchToFront = 0x05,
    /**
     *  切换后置摄像头
     */
    LGCameraActionSwitchToBack = 0x04,
};


/**
 *  音乐播放器控制动作
 */
typedef NS_ENUM(NSInteger, LGMusicAction) {
    /**
     *  播放音乐
     */
    LGMusicActionPlay = 0x00,
    /**
     *  停止播放
     */
    LGMusicActionPause,
    /**
     *  下一首
     */
    LGMusicActionNext,
    /**
     *  上一首
     */
    LGMusicActionPrevious,
    /**
     *  增加音量
     */
    LGMusicActionVolumeUp = 0x06,
    /**
     *  降低音量
     */
    LGMusicActionVolumeDown = 0x07,
};

/**
 *  查找手机控制动作
 */
typedef NS_ENUM(NSInteger, LGFindMobilePhoneAction) {
    /**
     *  查找手机，App播放特定音乐
     */
    LGFindMobilePhoneActionStart = 0x01,
    /**
     *  停止查找，App停止播放音乐
     */
    LGFindMobilePhoneActionEnd = 0x00,
};



/**
 *  星期周期
 */
typedef NS_ENUM(NSInteger, LGWeekPeriod) {
    /**
     *  星期一
     */
    LGWeekPeriodMonday    = 1<<0,
    /**
     *  星期二
     */
    LGWeekPeriodTuesday   = 1<<1 ,
    /**
     *  星期三
     */
    LGWeekPeriodWednesday = 1<<2,
    /**
     *  星期四
     */
    LGWeekPeriodThursday  = 1<<3,
    /**
     *  星期五
     */
    LGWeekPeriodFriday    = 1<<4,
    /**
     *  星期六
     */
    LGWeekPeriodSaturday  = 1<<5,
    /**
     *  星期日
     */
    LGWeekPeriodSunday    = 1<<6,
};

#endif /* LGCommonHeader_h */
