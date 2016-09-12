//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

@import Foundation;
@class LGPeripheralAgent;
@class LGBaseCommand;

typedef void(^LGBlockWithVoid)();
typedef void(^LGBlockWithInteger)(NSInteger integer);
typedef void(^LGBlockWithString)(NSString *string);
typedef void(^LGBlockWithArray)(NSArray *array);
typedef void(^LGBlockWithError)(NSError *error);

/**
 *  蓝牙命令基类
 */
@interface LGBaseCommand : NSObject

/**
 *  设备代理，需要在此设备中发送命令
 */
@property (nonatomic, strong) LGPeripheralAgent *agent;

/**
 *  用LGPeripheralAgent进行初始化
 */
+ (instancetype)commandWithAgent:(LGPeripheralAgent *)agent;
- (instancetype)initWithPeripheralAgent:(LGPeripheralAgent *)agent;

/**
 *  开始发送命令
 */
- (void)start;

/**
 *  取消当前的命令
 */
- (void)cancel;

#pragma mark - 子类实现以下三个方法

/**
 *  子类继承实现, 需要发送的命令：命令类型+数据长度+[数据]
 */
- (NSData *)sendingData;

/**
 *  设备可能只返回一次数据，或者连续不断的发送数据，所有数据都将经过这个方法, 请根据实际情况返回是否已完成接收。
 *
 *  @param responseData 数据
 *  @param error        错误
 *
 *  @return YES：完成接收所有数据，NO：还有数据需要接收
 */
- (BOOL)handleWithResponseData:(NSData *)responseData error:(NSError *)error;

@end

