//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGUserInfo;

typedef void(^LGUserInfoBlock)(LGUserInfo *userInfo);

/**
 *  设备用户资料
 */
@interface LGUserInfoCmd : LGBaseCommand

- (instancetype)setUserInfo:(LGUserInfo *)userInfo success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
- (instancetype)readUserInfoWithSuccess:(LGUserInfoBlock)success failure:(LGBlockWithError)failure;

@end

@interface LGUserInfo : NSObject
///用户性别, 男是NO，女是YES
@property (nonatomic, assign) BOOL gender;
///用户身高, 单位为cm
@property (nonatomic, assign) NSInteger height;
///用户体重, 单位为kg，精确到2位小数
@property (nonatomic, assign) double weight;

- (instancetype)initWithGender:(BOOL)gender height:(NSInteger)height weight:(double)weight;
@end
