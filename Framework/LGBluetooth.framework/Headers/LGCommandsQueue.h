//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"


@class LGPeripheralAgent;
@class LGBaseCommand;

/**
 *  所有命令处理完成回调
 *
 *  @param error 错误
 */
typedef void (^LGCommandsQueueBlock) (NSError *error);


/**
 *  批量发送命令，将命令放在队列里面，依次执行。如果某一个命令回调有错，立即退出所有命令。
 */
@interface LGCommandsQueue : LGBaseCommand

/**
 *  是否正在处理命令
 */
@property (nonatomic, assign,readonly) BOOL processing;

/**
 *  所有命令共享的LGPeripheralAgent，队列里面的命令不需要单独设置agent属性。
 */
@property (nonatomic, strong) LGPeripheralAgent *peripheralAgent;

/**
 *  添加单个命令
 *
 *  @param cmd 命令
 */
- (void)addCommandObject:(LGBaseCommand *)cmd;

/**
 *  批量添加命令
 *
 *  @param cmds 命令数组
 */
- (void)addCommands:(NSArray *)cmds;

/**
 *  开始执行所有命令
 *
 *  @param completion 执行完成所有命令之后回调
 */
- (void)startWithCompletion:(LGCommandsQueueBlock)completion;

/**
 *  取消当前所有命令
 */
- (void)cancel;
@end
