//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"
@class LGSportData;
/**
 *  运动回调
 */
typedef void(^LGSportDataBlock)(NSArray<LGSportData *> *datas);

/**
 *  读取历史运动数据
 */
@interface LGHistorySportDataCmd : LGBaseCommand

- (instancetype)readDataWithSuccess:(LGSportDataBlock)success failure:(LGBlockWithError)failure;

@end

/**
 *  运动数据
 */
@interface LGSportData : NSObject
///时间
@property (nonatomic, strong) NSDate *date;
///步数
@property (nonatomic, assign) NSInteger steps;
///卡路里 ，小卡单位(步数太小时，可能卡路里为0)
@property (nonatomic, assign) NSInteger calories;

/**
 *  距离计算，根据用户的步数、性别、身高计算
 *
 *  @param female YES：女性，NO：男性
 *  @param cm     身高，单位为厘米
 *  @param steps  步数
 *
 *  @return 返回步数对应的距离，单位为米
 */
+ (NSInteger)distanceWithGender:(BOOL)female  height:(NSInteger)cm steps:(NSInteger)steps;
@end
