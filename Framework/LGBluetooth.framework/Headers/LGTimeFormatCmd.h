//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"
/**
 *  时间小时制
 */
typedef NS_ENUM(NSInteger, LGTimeFormat) {
    /**
     *  24小时制
     */
    LGTimeFormat24,
    /**
     *  12小时制
     */
    LGTimeFormat12,
};

/**
 *  时间格式设置
 */
@interface LGTimeFormatCmd : LGBaseCommand
/**
 *  获取当前手机系统时间格式是否24小时
 */
+ (LGTimeFormat)systemTimeFormat;

/**
 *  设置时间格式
 *
 *  @param format  时间格式
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)setTimeFormat:(LGTimeFormat)format success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
/**
 *  读取时间格式
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return self
 */
- (instancetype)readTimeFormatWithSuccess:(LGBlockWithInteger)success failure:(LGBlockWithError)failure;
@end
