//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) zhangwen. All rights reserved.
//

@import Foundation;
@import LGBluetooth;
@import iOSDFULibrary;
//https://github.com/NordicSemiconductor/IOS-DFU-Library.git
//支持carthage 和 cocoapods


@class LGPeripheralAgent;
@class LGDFUManager;

/**
 *  升级的回调
 */
@protocol LGDFUManagerDelegate <NSObject>

/**
 *  进入升级模式成功
 *
 */
- (void)DFUManagerEnterUpgradeMode:(LGDFUManager *)manager;

/**
 *  当前的升级进度更新
 *
 *  @param manager  LGDFUManager
 *  @param progress 百分比，当返回100时还不是真正结束，请在`DFUManagerCompleted:`回调处理结束
 */
- (void)DFUManager:(LGDFUManager *)manager onUploadProgress:(NSInteger)progress;

/**
 *  完成升级
 */
- (void)DFUManagerCompleted:(LGDFUManager *)manager;

/**
 *  有错误发生
 *
 *  @param manager   LGDFUManager
 *  @param message   错误描述
 */
- (void)DFUManager:(LGDFUManager *)manager didErrorOccurWithMessage:(NSString *)message;
@end

/**
 *  固件升级管理器
 */
@interface LGDFUManager : NSObject

@property (nonatomic, weak) id<LGDFUManagerDelegate> delegate;

/**
 *  初始化固件升级管理器
 *
 *  @param agent     升级设备
 *
 */
- (instancetype)initWithPeripheralAgent:(LGPeripheralAgent *)agent;

/**
 *  开始升级
 *
 *  @param fileURL   固件文件路径
 */
- (void)startWithfileURL:(NSURL *)fileURL;
@end
