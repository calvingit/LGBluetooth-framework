//
//  LGHeatControlsCmd.h
//  LGBluetoothExample
//
//  Created by zhangwen on 16/7/26.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGBluetooth.h"

/**
 *  身体部位
 */
typedef NS_ENUM(NSInteger, LGBodyPart) {
    /**
     *  腰部
     */
    LGBodyPartWaist    = 0,
    /**
     *  肩部
     */
    LGBodyPartShoulder = 1,
    /**
     *  腹部
     */
    LGBodyPartAbdomen  = 2,
};

/**
 *  温度等级
 */
typedef NS_ENUM(NSInteger, LGHeatLevel) {
    /**
     *  关闭
     */
    LGHeatLevelClose = 0,
    /**
     *  一挡
     */
    LGHeatLevelOne,
    /**
     *  二挡
     */
    LGHeatLevelTwo,
    /**
     *  三挡
     */
    LGHeatLevelThree,
};

/**
 *  温度控制
 */
@interface LGHeatControlsCmd : LGBaseCommand

/**
 *  读取全身部位的温度等级
 *
 *  @param success 成功回调，dict的key是NSNumber(LGBodyPart)，代表身体部位；value也是NSNumber(LGHeatLevel),代表温度等级
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)readAllHeatLevelsWithSuccess:(void(^)(NSDictionary *dict))success failure:(LGBlockWithError)failure;
/**
 *  设置身体某部位的温度
 *
 *  @param level   温度等级
 *  @param part    身体部位
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)setLevel:(LGHeatLevel)level bodyPart:(LGBodyPart)part success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

@end


