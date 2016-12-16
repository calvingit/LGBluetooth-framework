//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//
@import Foundation;
@import CoreBluetooth;
@class LGPeripheral;
@class LGCentralManager;

#pragma mark - 回调blocks -
//一般操作回调
typedef void(^LGPeripheralOperationResultCallback)(LGPeripheral *peripheral, NSError *error);
//发现服务特征回调
typedef void(^LGPeripheralDiscoverCharacteristicInServiceCallback)(LGPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error);
//特征更新数据回调
typedef void(^LGPeripheralUpdateValueFromCharacteristicCallback)(LGPeripheral *peripheral, NSData *value);
//读取信号强度回调
typedef void(^LGPeripheralReadRSSICallback)(LGPeripheral *peripheral, NSNumber *RSSI, NSError *error);
//从特征读取数据
typedef void(^LGPeripheralReadDataFromCharacteristicCallback)(LGPeripheral *peripheral, NSData *value, NSError *error);


/**
 *  LGPeripheral连接状态变化
 */
@protocol LGPeripheralConnectionDelegate <NSObject>
@optional
/**
 *  连接成功
 */
- (void)peripheralDidConnect:(LGPeripheral *)peripheral;

/**
 *  断开连接
 */
- (void)peripheralDidDisconnect:(LGPeripheral *)peripheral;
@end

/**
 *  设备封装
 */
@interface LGPeripheral : NSObject <CBPeripheralDelegate>

#pragma mark - Public Properties -
/**
 *  是否连接状态，可能是和系统蓝牙连接，也可能是和别的设备连接
 */
@property (assign, nonatomic, readonly) BOOL connected;

/**
 *  CBPeripheral对象
 */
@property (strong, nonatomic, readonly) CBPeripheral *cbPeripheral;

/**
 *  LGCentralManager对象
 */
@property (strong, nonatomic, readonly) LGCentralManager *manager;

/**
 *  UUID, 设备的唯一标识符
 */
@property (copy, nonatomic, readonly) NSString *UUIDString;

/**
 *  设备名字
 */
@property (copy, nonatomic, readonly) NSString *name;

/**
 *  广播数据
 *  注意: 
 *  1.通过LGCentralManager的scanPeripheralsWithServices:allowDuplicates函数扫描到设备才有广播
 *  2.如果是retrievePeripheralsWithIdentifiers或者retrieveConnectedPeripheralsWithServices的则为nil
 */
@property (strong, nonatomic, readonly) NSDictionary *advertisingData;

/**
 *  蓝牙信号强度，负整数，值越大，信号越好。可以通过函数readRSSIWithCompletion:读取实时信号强度
 *  注意：
 *  1.通过LGCentralManager的scanPeripheralsWithServices:allowDuplicates函数扫描到设备会有默认信号
 *  2.如果是retrievePeripheralsWithIdentifiers或者retrieveConnectedPeripheralsWithServices的函数获取的
 *  设备则为nil，需要手动获取信号强度才会更新。
 */
@property (nonatomic, strong, readonly) NSNumber *RSSI;

@property (nonatomic, copy) LGPeripheralOperationResultCallback connectionBlock;

@property (nonatomic, weak)  id <LGPeripheralConnectionDelegate> connectionDelagate;

#pragma mark - Public Methods -

/**
 *  连接设备
 *
 *  @param intervals   超时时间
 *  @param completion  连接回调
 */
- (void)connectWithTimeout:(NSUInteger)intervals
                completion:(LGPeripheralOperationResultCallback)completion;

/**
 * 断开连接
 */
- (void)disconnect;

/**
 *  发现服务和特征
 *
 *  @param characteristicUUID 服务包含的特征UUID
 *  @param serviceUUID        需要搜索的服务UUID
 *  @param completion         如果找到了特征，返回CBCharacteristic对象。如果未找到返回error。
 */
- (void)discoverCharacteristic:(NSString *)characteristicUUID
                     inService:(NSString *)serviceUUID
                    completion:(LGPeripheralDiscoverCharacteristicInServiceCallback)completion;

/**
 *  开启某个特征的通知属性（可用于标准心率等）
 *
 *  @param characteristic       CBCharacteristic对象，可从discoverCharacteristic:inService:completion函数的返回结果中获取
 *  @param completion           如果设置成功，error参数为nil。
 */
- (void)setNotifyValue:(BOOL)opened forCharacteristic:(CBCharacteristic *)characteristic completion:(LGPeripheralOperationResultCallback)completion;

/**
 *  设置特征的数据回调。如果characteristic开启了通知属性，那么需要一个接收数据的回调。
 *
 *  @param characteristic      CBCharacteristic对象，可从discoverCharacteristic:inService:completion函数的返回结果中获取
 *  @param updateValueCallback 这个特征有任何新的数据都将经过这个callback
 */
- (void)setCharacteristic:(CBCharacteristic *)characteristic  updateValueCallback:(LGPeripheralUpdateValueFromCharacteristicCallback)updateValueCallback;

/**
 *  写入数据到characteristic
 *
 *  @param data           数据
 *  @param characteristic CBCharacteristic对象，可从discoverCharacteristic:inService:completion函数的返回结果中获取
 *  @param completion           如果设置成功，error参数为nil。
 */
- (void)writeData:(NSData *)data intoCharacteristic:(CBCharacteristic *)characteristic
       completion:(LGPeripheralOperationResultCallback)completion;

/**
 *  从characteristic读取数据
 *
 *  @param characteristic CBCharacteristic对象，可从discoverCharacteristic:inService:completion函数的返回结果中获取
 *  @param completion     value为返回的数据，如果是失败请查看error
 */
- (void)readDataFromCharacteristic:(CBCharacteristic *)characteristic
                        completion:(LGPeripheralReadDataFromCharacteristicCallback)completion;

/**
 *  读取实时信号强度
 *
 *  @param completion 返回实时信号强度
 */
- (void)readRSSIWithCompletion:(LGPeripheralReadRSSICallback)completion;



@end
