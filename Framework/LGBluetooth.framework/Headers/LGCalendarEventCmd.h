//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGCalendarEvent;

/**
 *  日历事件设置
 */
@interface LGCalendarEventCmd : LGBaseCommand
//清空日历
- (LGCalendarEventCmd *)cleanUpCalendarsWithSuccess:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

//添加日历(最多5个)
- (LGCalendarEventCmd *)addCalendarEvent:(LGCalendarEvent *)event success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  读取设备日历事件
 */
- (LGCalendarEventCmd *)readCalendarsSuccess:(LGBlockWithArray)success failure:(LGBlockWithError)failure;
@end


@class EKEvent;
/**
 *  日历
 */
@interface LGCalendarEvent : NSObject
@property (nonatomic, assign) NSInteger index;   //索引
@property (nonatomic, strong) NSDate    *date;   //日期
@property (nonatomic, copy  ) NSString  *content;//内容(读取的时候不返回)
/**
 *  使用系统的日历初始化
 *
 *  @param event 系统日历的startDate作为date， 系统日历的title作为content
 *  @param index 索引
 *
 */
- (instancetype)initWithEKEvent:(EKEvent *)event atIndex:(NSInteger)index;

@end