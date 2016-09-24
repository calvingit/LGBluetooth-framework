//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//


#import "LGBaseCommand.h"

typedef void(^LGGPSInfoCmdBlock)(NSData *data);

/**
 *  GPS信息，返回十六进制数据，需要自己解析
 */
@interface LGGPSInfoCmd : LGBaseCommand
- (instancetype)readInfoWithSuccess:(LGGPSInfoCmdBlock)success failure:(LGBlockWithError)failure;
@end
