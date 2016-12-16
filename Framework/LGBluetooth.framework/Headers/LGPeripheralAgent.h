//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//
#import "LGCommonHeader.h"
@import Foundation;
@class LGBaseCommand;
@class LGPeripheral;
@class LGPeripheralAgent;
@protocol LGPeripheralAgentDelegate;


/**
 *  设备代理类，用于发送具体命令，协议解析等
 */
@interface LGPeripheralAgent : NSObject

@property (nonatomic, strong, readonly) LGPeripheral *peripheral;
/**
 *  是否准备好处理数据
 */
@property (nonatomic, assign) BOOL readyForWriting;

@property (nonatomic, strong) id <LGPeripheralAgentDelegate> delegate;

/**
 *  断开之后是否需要重连，默认YES
 */
@property (nonatomic, assign) BOOL reconnect;

/**
 *  初始化。内部有大约1秒钟的查找蓝牙服务特征的处理，所以不能立即调用，需要延时调用
 *
 */
- (instancetype)initWithPeripheral:(LGPeripheral *)aPeripheral;


/**
 *  写数据到设备,需要readyForWriting为YES的时候才能发送
 *
 *  @param aData     数据，请看协议文档
 *  @param intervals 响应超时时间
 *  @param aCallback 回调
 */
- (void)writeData:(NSData *)aData
        intervals:(NSInteger)intervals
       completion:(void(^)(NSData *data, NSError *error))aCallback;

/**
 *  开启实时心率更新
 *
 *  @param enable 开关
 */
- (void)enableRealTimeHeartRateUpdate:(BOOL)enable completion:(void(^)(NSError *error))completion;
@end

/**
 *  设备端操作时发送给App的命令回调
 */
@protocol LGPeripheralAgentDelegate <NSObject>
@optional
/**
 *  实时心率数据
 *
 *  @param peripheralAgent LGPeripheralAgent 对象
 *  @param heartRate       心率数据
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent heartRateUpdate:(NSInteger)heartRate;

/**
 *  相机控制操作
 *
 *  @param peripheralAgent LGPeripheralAgent 对象
 *  @param cameraAction    LGCameraAction 类型
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent cameraControl:(LGCameraAction)cameraAction;

/**
 *  音乐控制操作
 *
 *  @param peripheralAgent LGPeripheralAgent 对象
 *  @param musicAction     LGMusicAction 类型
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent musicControl:(LGMusicAction)musicAction;

/**
 *  查找手机控制操作
 *
 *  @param peripheralAgent LGPeripheralAgent 对象
 *  @param action          LGFindMobilePhoneAction 类型
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent findMobilePphone:(LGFindMobilePhoneAction)action;

/**
 *  拨打电话号码
 *
 *  @param peripheralAgent LGPeripheralAgent 对象
 *  @param phoneNumber     电话号码
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent dialingPhoneNumber:(NSString *)phoneNumber;

/**
 *  挂断当前电话
 */
- (void)peripheralAgentHangUpPhoneCall:(LGPeripheralAgent *)peripheralAgent;

@end
