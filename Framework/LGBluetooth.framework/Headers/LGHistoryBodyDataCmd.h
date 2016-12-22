//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"
@class LGBodyData;

/**
 *  体征数据回调
 */
typedef void(^LGHistoryBodyDataBlock)(NSArray<LGBodyData *> *datas);

/**
 *  读取体征的历史数据
 */
@interface LGHistoryBodyDataCmd : LGBaseCommand

- (instancetype)readDataWithSuccess:(LGHistoryBodyDataBlock)success failure:(LGBlockWithError)failure;

@end

/**
 *  体征数据
 */
@interface LGBodyData : NSObject
///心率值
@property (nonatomic, assign)  NSInteger hr;
///prv
@property (nonatomic, assign)  NSInteger prv;
///时间
@property (nonatomic, strong)  NSDate *date;
@end
