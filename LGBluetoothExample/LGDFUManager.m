//
//  LGDFUManager.m
//  LGBluetoothExample
//
//  Created by zhangwen on 16/8/13.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGDFUManager.h"

#define kMaxRetryCount 4

@interface LGDFUManager ()<LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>

//@property (nonatomic, strong) LGPeripheral *peripheral;
@property (nonatomic, strong) LGPeripheralAgent *peripheralAgent; ///升级设备

@property (nonatomic, strong) DFUFirmware *firmware;
@property (strong, nonatomic) DFUServiceController *controller;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) LGPeripheral *upgradePeripheral;

@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger progress;

@end

@implementation LGDFUManager
- (instancetype)initWithPeripheralAgent:(LGPeripheralAgent *)agent{
    if (self = [super init]) {
        _peripheralAgent = agent;
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    return self;
}

- (void)dealloc{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

//恢复delegate，否则被DFU接管了，以后连接不上。
- (void)resetDelegate{
    [LGCentralManager sharedInstance].manager.delegate = [LGCentralManager sharedInstance];
    self.peripheralAgent.peripheral.cbPeripheral.delegate = self.peripheralAgent.peripheral;
}

- (void)setProgress:(NSInteger)progress{
    if (_progress < progress) {
        _progress = progress;
        if ([self.delegate respondsToSelector:@selector(DFUManager:onUploadProgress:)]) {
            [self.delegate DFUManager:self onUploadProgress:_progress];
        }
    }
}

- (void)startWithfileURL:(NSURL *)fileURL{
    _progress = 0;
    self.retryCount = 0;
    
    if(!fileURL) return;
    if (!_peripheralAgent) return;
    
    _firmware = [[DFUFirmware alloc] initWithUrlToZipFile:fileURL];
    [self resetDelegate];
    
    if (!self.peripheralAgent.peripheral.connected) {
        if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
            [self.delegate DFUManager:self didErrorOccurWithMessage:@"Peripheral not connected"];
        }
        return;
    }
    
    LGFirmwareUpgradeCmd *cmd = [[LGFirmwareUpgradeCmd alloc] initWithPeripheralAgent:self.peripheralAgent];
    [cmd startWithSuccess:^{
        if ([self.delegate respondsToSelector:@selector(DFUManagerEnterUpgradeMode:)]) {
            [self.delegate DFUManagerEnterUpgradeMode:self];
        }
        [self scanDFUDevice];
    } failure:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
            [self.delegate DFUManager:self didErrorOccurWithMessage:@"Peripheral enter upgrade mode failed!"];
        }
    }];
}

- (void)scanDFUDevice{
    [self resetDelegate];
    [[LGCentralManager sharedInstance] scanPeripheralsWithServices:@[kDFUServiceUUID] interval:5 completion:^(LGCentralManager *manager, NSArray *scanedPeripherals) {
        for (LGPeripheral *peripheral in scanedPeripherals) {
            if ([peripheral.name hasPrefix:@"OTA"]) {
                self.upgradePeripheral = peripheral;
                [self performDFUWithPeripheral:peripheral.cbPeripheral];
                return;
            }
        }
        [self didErrorOccur:0 withMessage:@"No OTA peripherals scaned"];
    }];
}

-(void)performDFUWithPeripheral:(CBPeripheral *)peripheral{
    // To start the DFU operation the DFUServiceInitiator must be used
    DFUServiceInitiator *initiator =
    [[DFUServiceInitiator alloc] initWithCentralManager:[LGCentralManager sharedInstance].manager
                                                 target:peripheral];
    [initiator withFirmwareFile:self.firmware];
    initiator.forceDfu = NO;
    initiator.packetReceiptNotificationParameter = 12;
    initiator.logger = self;
    initiator.delegate = self;
    initiator.progressDelegate = self;
    self.controller = [initiator start];
}

#pragma mark - DFU Service delegate methods

-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    NSLog(@"DFU Log:%ld %@", (long) level, message);
}

-(void)didStateChangedTo:(enum State)state
{
    switch (state) {
        case StateConnecting:
            break;
        case StateStarting:
            break;
        case StateEnablingDfuMode:
            break;
        case StateUploading:
            break;
        case StateValidating:
            break;
        case StateDisconnecting:
            break;
        case StateCompleted:{
            [self resetDelegate];
            if ([self.delegate respondsToSelector:@selector(DFUManagerCompleted:)]) {
                [self.delegate DFUManagerCompleted:self];
            }
        }
            break;
        case StateAborted:{
            if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
                [self.delegate DFUManager:self didErrorOccurWithMessage:@"DFU aborted!"];
            }
        }
            break;
    }
}

-(void)onUploadProgress:(NSInteger)part totalParts:(NSInteger)totalParts progress:(NSInteger)percentage
currentSpeedBytesPerSecond:(double)speed avgSpeedBytesPerSecond:(double)avgSpeed{
    self.progress = percentage;
}

-(void)didErrorOccur:(enum DFUError)error withMessage:(NSString *)message{
    NSLog(@"DFU error: %@", message);
    self.retryCount += 1;
    if (self.retryCount < kMaxRetryCount){
        [self scanDFUDevice];
    }else{
        if ([self.delegate respondsToSelector:@selector(DFUManager:didErrorOccurWithMessage:)]) {
            [self.delegate DFUManager:self didErrorOccurWithMessage:message];
        }
    }
}


@end
