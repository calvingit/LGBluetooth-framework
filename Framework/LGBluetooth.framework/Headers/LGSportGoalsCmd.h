//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"
@class LGSportGoals;

typedef void(^LGSportGoalsBlock)(LGSportGoals *goals);

/**
 * 运动目标设置
 */
@interface LGSportGoalsCmd : LGBaseCommand

- (instancetype)setGoals:(LGSportGoals *)goals success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
- (instancetype)readGoalsWithSuccess:(LGSportGoalsBlock)success failure:(LGBlockWithError)failure;

@end

/**
 *  运动目标, 达到目标时设备将震动提醒
 *  如果不需要某个目标，将其设为0
 */
@interface LGSportGoals : NSObject
@property (nonatomic, assign) NSInteger steps;//步数
@property (nonatomic, assign) NSInteger calory;//卡路里(单位为卡)
@property (nonatomic, assign) NSInteger distance;//距离(单位为米)
@end
