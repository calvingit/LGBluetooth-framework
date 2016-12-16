//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseSettingCommand.h"

/**
 *  如果确定此设备是用户需要连接的设备，则发送此命令确认验证码正确
 *  设备收到这条命令之后会关闭验证码界面
 */
@interface LGComfirmPairingCodeCmd : LGBaseSettingCommand

@end
