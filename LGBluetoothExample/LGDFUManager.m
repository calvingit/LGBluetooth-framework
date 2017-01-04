//
//  LGDFUManager.m
//  LGBluetoothExample
//
//  Created by zhangwen on 16/8/13.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGDFUManager.h"
@import CoreBluetooth;

#define kMaxRetryCount 4

@interface LGDFUManager ()<CBCentralManagerDelegate,LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>

@property (nonatomic, strong) LGPeripheral *peripheral; ///升级设备
@property (nonatomic, assign) BOOL isOTA;

@property (nonatomic, strong) DFUFirmware *firmware;
@property (strong, nonatomic) DFUServiceController *controller;
@property (nonatomic, strong) NSURL *fileURL;

//DFULibrary需要使用
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *dfuPeripheral;

@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger progress;

@property (nonatomic, strong) NSTimer *scanTimer;

@end

@implementation LGDFUManager
- (instancetype)initWithPeripheral:(LGPeripheral *)aPeripheral{
    if (self = [super init]) {
        _peripheral = aPeripheral;
        if ([aPeripheral.name hasPrefix:@"OTA_"]) {
            _isOTA = YES;
            _dfuPeripheral  = aPeripheral.cbPeripheral;
            _centralManager = [LGCentralManager sharedInstance].manager;
        }else{
            _isOTA = NO;
            _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        }
    }
    return self;
}

//恢复delegate，否则被DFU接管了，以后连接不上。
- (void)resetDelegate{
    [LGCentralManager sharedInstance].manager.delegate = [LGCentralManager sharedInstance];
    self.peripheral.cbPeripheral.delegate = self.peripheral;
}

//设置进度，DFULibrary会进行两次升级，这里避免进度重头开始
- (void)setProgress:(NSInteger)progress{
    if (_progress < progress) {
        _progress = progress;
        if ([self.delegate respondsToSelector:@selector(DFUManager:onUploadProgress:)]) {
            [self.delegate DFUManager:self onUploadProgress:_progress];
        }
    }
}

//开始升级
- (void)startWithfileURL:(NSURL *)fileURL{
    _progress = 0;
    self.retryCount = 0;
    
    if(!fileURL) return;

    self.firmware = [[DFUFirmware alloc] initWithUrlToZipFile:fileURL];
    [self resetDelegate];
    
    //如果已经进入了升级模式，直接进行升级
    if (self.isOTA) {
        [self performDFUWithPeripheral:self.dfuPeripheral];
    }else{
        [self enterUpgradeMode];
    }
}

// 进入升级模式
- (void)enterUpgradeMode{
    LGPeripheralAgent *agent = [[LGPeripheralAgent alloc] initWithPeripheral:self.peripheral];
    
    //等待agent初始化完成，3秒后发送升级命令
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LGFirmwareUpgradeCmd *cmd = [[LGFirmwareUpgradeCmd alloc] initWithPeripheralAgent:agent];
        [cmd startWithSuccess:^{
            if ([self.delegate respondsToSelector:@selector(DFUManagerEnterUpgradeMode:)]) {
                [self.delegate DFUManagerEnterUpgradeMode:self];
            }

            //等待设备重启，更换设备名称为"OTA_EGP01"
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self scanDFUDevice];
            });
        } failure:^(NSError *error) {
            if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
                [self.delegate DFUManager:self didErrorOccurWithMessage:
                 error.description];
            }
        }];
    });
}


/**
 扫描升级设备
 */
- (void)scanDFUDevice{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kDFUServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeoutForScanning) userInfo:nil repeats:NO];
}

- (void)timeoutForScanning{
    [self.centralManager stopScan];
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
        [self.delegate DFUManager:self didErrorOccurWithMessage:
         @"Timeout for scanning OTA device"];
    }
}

// 初始化DFUServiceController
-(void)performDFUWithPeripheral:(CBPeripheral *)peripheral{
    // To start the DFU operation the DFUServiceInitiator must be used
    DFUServiceInitiator *initiator =[[DFUServiceInitiator alloc] initWithCentralManager:self.centralManager target:peripheral];
    [initiator withFirmware:self.firmware];
    initiator.forceDfu = NO;
    initiator.packetReceiptNotificationParameter = 12;
    initiator.logger = self;
    initiator.delegate = self;
    initiator.progressDelegate = self;
    self.controller = [initiator start];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"CBCentralManager 已准备好");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([peripheral.name hasPrefix:@"OTA_"]) {
        self.dfuPeripheral = peripheral;
        [self.centralManager stopScan];
        [self.scanTimer invalidate];
        self.scanTimer = nil;
        [self performDFUWithPeripheral:peripheral];
    }
}

#pragma mark - DFU Service delegate methods

-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    NSLog(@"DFU Log:%ld %@", (long) level, message);
}

- (void)dfuStateDidChangeTo:(enum DFUState)state
{
    switch (state) {
        case DFUStateConnecting:
            break;
        case DFUStateStarting:
            break;
        case DFUStateEnablingDfuMode:
            break;
        case DFUStateUploading:
            break;
        case DFUStateValidating:
            break;
        case DFUStateDisconnecting:
            break;
        case DFUStateCompleted:{
            if (!self.isOTA) {
                [self resetDelegate];
            }
            if ([self.delegate respondsToSelector:@selector(DFUManagerCompleted:)]) {
                [self.delegate DFUManagerCompleted:self];
            }
        }
            break;
        case DFUStateAborted:{
            if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
                [self.delegate DFUManager:self didErrorOccurWithMessage:@"DFU aborted!"];
            }
        }
            break;
    }
}

-(void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    self.progress = progress;
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message
{
    NSLog(@"DFU error: %@", message);
    self.retryCount++;
    if (self.retryCount < kMaxRetryCount) {
        //延迟两秒后再次执行，这里不需要搜索设备了，已经保存在self.dfuPeripheral
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performDFUWithPeripheral:self.dfuPeripheral];
        });
    }else {
        if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
            [self.delegate DFUManager:self didErrorOccurWithMessage:message];
        }
    }

}


@end
