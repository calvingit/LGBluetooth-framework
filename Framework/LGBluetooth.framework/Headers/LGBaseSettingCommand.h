//
//  LGBaseSettingCommand.h
//  LGBluetoothExample
//
//  Created by zhangwen on 16/8/29.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"
/**
 *  设置命令，即发送命令之后，设备只会响应结果，不会回传数据。
 *  继承只会只需要实现sendingData方法即可
 */
@interface LGBaseSettingCommand : LGBaseCommand
@property (nonatomic, copy) LGBlockWithVoid successCallback;
@property (nonatomic, copy) LGBlockWithError failureCallback;
- (void)startWithSuccess:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
@end
