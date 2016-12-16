//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"
#import "LGCommonHeader.h"
/**
 *  提醒类型
 */
typedef NS_ENUM(NSInteger, LGAlarmClockType) {
    LGAlarmClockTypeSport       = 0,   /// 运动
    LGAlarmClockTypeSleep       = 1,   /// 睡觉
    LGAlarmClockTypeEat         = 2,   /// 吃饭
    LGAlarmClockTypeMedicine    = 3,   /// 吃药
    LGAlarmClockTypeWakeup      = 4,   /// 醒来
    LGAlarmClockTypeMeeting     = 5,   /// 开会
    LGAlarmClockTypeUserDefined = 255  /// 自定义
};

/**
 *  提醒类
 */
@interface LGAlarmClock : NSObject
@property (nonatomic, assign) NSInteger        index;     //索引,唯一值，读取时返回，添加时忽略
@property (nonatomic, assign) BOOL             status;    //YES:打开, NO:关闭
@property (nonatomic, copy  ) NSString         *time;     //时间,格式为"HH:mm",如"08:30"
@property (nonatomic, assign) LGAlarmClockType type;      //提醒类型
@property (nonatomic, assign) NSInteger        weekPeriod;//星期周期, LGWeekPeriod
@end

/**
 *  提醒的增删改查命令
 */
@interface LGAlarmClockCmd : LGBaseCommand

/**
 *  读取设备的所有提醒
 *
 *  @param success 返回数组类型：NSArray<LGAlarmClock *> *
 *  @param failure 读取失败
 *
 */
- (instancetype)readClocksWithSuccess:(LGBlockWithArray)success failure:(LGBlockWithError)failure;

/**
 *  删除设备的所有提醒
 *
 *  @param success 删除成功
 *  @param failure 删除失败
 *
 */
- (instancetype)cleanUpClocksWithSuccess:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  添加一个提醒到设备
 *
 *  @param clock   提醒，不需要提供index
 *  @param success 添加成功
 *  @param failure 添加失败
 *
 */
- (instancetype)addClock:(LGAlarmClock *)clock success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  修改提醒
 *  @param index   需要修改的提醒索引
 *  @param clock   新的提醒
 *  @param success 修改成功
 *  @param failure 修改失败
 *
 */
- (instancetype)changeClockAtIndex:(NSInteger)index withNewClock:(LGAlarmClock *)clock success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
/**
 *  删除提醒
 *
 *  @param index   提醒索引
 *  @param success 删除成功
 *  @param failure 删除失败
 *
 */
- (instancetype)deleteClockAtIndex:(NSInteger)index success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

@end
