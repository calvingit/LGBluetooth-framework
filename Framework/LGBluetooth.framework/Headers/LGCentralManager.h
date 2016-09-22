//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@class LGPeripheral;
@class LGCentralManager;

/*
 * 蓝牙状态更新通知
 */
FOUNDATION_EXPORT NSString *const kCBCentralManagerStateNotification;


/**
 扫描回调

 @param manager           LGCentralManager
 @param scanedPeripherals 所有扫描到的设备，按信号强度升序排列
 */
typedef void(^LGCentralManagerScanningBlock)(LGCentralManager *manager, NSArray *scanedPeripherals);

/**
 * 蓝牙模块封装，对App来说只需要一个中央管理器，所以做成单例模式
 */
@interface LGCentralManager : NSObject <CBCentralManagerDelegate>
/**
 * Core bluetooth的 Central manager
 */
@property (strong, nonatomic, readonly) CBCentralManager *manager;

/**
 * 是否正在扫描
 */
@property (nonatomic, getter = isScanning) BOOL scanning;

/**
 * 蓝牙开关状态, YES:打开，NO:关闭
 */
@property (assign, nonatomic, readonly) BOOL poweredOn;

/**
 *  蓝牙未授权状态, YES:未授权, NO:已授权
 *  iOS 10之后需要在info.plist里面添加NSBluetoothPeripheralUsageDescription
 */
@property (assign, nonatomic, readonly) BOOL unauthorized;

/**
 *  App启动时进行初始化
 */
+ (void)startUp;

/**
 *  根据LGPeripheral的UUIDString获取已连接设备
 *
 *  @param uuids 可以是多个设备
 *
 *  @return 已连接设备
 */
- (NSArray<LGPeripheral *> *)retrievePeripheralsWithIdentifiers:(NSArray<NSString *> *)UUIDs;

/**
 *  根据LGPeripheral的服务UUID获取系统已连接的设备，在"设置-蓝牙"列表可以看到“已连接”标志的设备
 *
 *  @param serviceUUIDs 服务UUID
 *
 *  @return 已连接的设备
 */
- (NSArray<LGPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<NSString *> *)serviceUUIDs;

/**
 *  扫描指定服务的设备
 *
 *  @param serviceUUIDs 包含数组内任一服务的设备都会搜索到；可以为空，将扫描任何设备
 *  @param interval     扫描时间
 *  @param completion   扫描结束返回所有设备
 */
- (void)scanPeripheralsWithServices:(NSArray<NSString *> *)serviceUUIDs
                           interval:(NSTimeInterval)interval
                         completion:(LGCentralManagerScanningBlock)completion;

/**
 *  停止扫描
 */
- (void)stopScanForPeripherals;

/**
 * 单例，在App启动的时候调用一次，更新蓝牙状态
 */
+ (LGCentralManager *)sharedInstance;

@end
