//
//  LGFirmwareViewController.h
//  LGBluetoothExample
//
//  Created by zhangwen on 16/7/20.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LGPeripheral;
@interface LGFirmwareViewController : UIViewController
@property (nonatomic, strong) LGPeripheral *peripheral;
@end
