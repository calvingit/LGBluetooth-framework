//
//  LGMapDataManager.h
//  LGBluetooth
//
//  Created by zhangwen on 2016/10/11.
//  Copyright © 2016年 zhangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGPeripheral;

/**
 错误类型
 
 - LGMapErrorTypeNoError:       成功
 - LGMapErrorTypeConnectFailed: 设备未连接、连接不成功超时
 - LGMapErrorTypeWrongURL:      map文件URL错误
 - LGMapErrorTypeFailed:        升级失败
 - LGMapErrorTypeLengthWrong:   升级长度错误
 - LGMapErrorTypeCommandWrong:  升级命令错误
 - LGMapErrorTypeCRCWrong:      升级包CRC校验错误
 - LGMapErrorTypeUnknown:       未知错误
 */
typedef NS_ENUM(NSInteger, LGMapErrorType){
    LGMapErrorTypeNoError = 0x10,
    LGMapErrorTypeConnectFailed = 0x00,
    LGMapErrorTypeWrongURL = 0x01,
    LGMapErrorTypeFailed = 0x11,
    LGMapErrorTypeLengthWrong = 0x12,
    LGMapErrorTypeCommandWrong = 0x13,
    LGMapErrorTypeCRCWrong = 0x14,
    LGMapErrorTypeUnknown = 0xFF,
};

@protocol LGMapDataManagerDelegate <NSObject>
/**
 进入升级模式, 最先回调。
 */
- (void)enterUpdatingMode;

/**
 完成更新
 */
- (void)updatingSuccessful;

/**
 更新进度

 @param progress 进度
 */
- (void)updatingProgress:(float)progress;

/**
 中断更新

 @param error 发生错误
 */
- (void)interupteWithErrorType:(LGMapErrorType)errorType message:(NSString *)message;

@end


/**
 地图更新管理类,具备断点续传功能
 */
@interface LGMapDataManager : NSObject

@property (nonatomic, weak) id<LGMapDataManagerDelegate> delegate;


/**
 每个地图数据包大小，初始化为4096字节，再加上11个字节的包头，所以每次下发4096 + 11个字节
 */
@property (assign, nonatomic) NSInteger packageLength;

/**
 初始化

 @param url map文件路径
 @param aPeripheral 设备

 @return LGMapDataManager 对象
 */
- (instancetype)initWithFileUrl:(NSString *)url peripheral:(LGPeripheral *)aPeripheral;

/**
 开始更新
 */
- (void)startUpdating;

/**
 手动断开传输过程
 注意: 此方法仅用于测试情况，正常情况下不需要调用这个函数
 */
- (void)stopUpdatingForTest;
@end
