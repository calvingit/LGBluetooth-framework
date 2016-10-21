//
//  LGBluetooth.h
//  LGBluetooth
//
//  Created by zhangwen on 16/9/12.
//  Copyright © 2016年 zhangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Framework 版本
 */
FOUNDATION_EXPORT NSString * const kLGBluetoothVersion;

#import "LGCommonHeader.h"
#import "LGCentralManager.h"
#import "LGPeripheral.h"
#import "LGPeripheralAgent.h"
#import "LGCommandsQueue.h"
#import "LGSerialNumberCmd.h"
#import "LGFirmwareInformationCmd.h"
#import "LGUserInfoCmd.h"
#import "LGTimeSettingCmd.h"
#import "LGRestoreFactorySettingsCmd.h"
#import "LGNotificationsCmd.h"
#import "LGPairingCodeCmd.h"
#import "LGComfirmPairingCodeCmd.h"
#import "LGSedentaryReminderCmd.h"
#import "LGAlarmClockCmd.h"
#import "LGQuitCameraCmd.h"
#import "LGWeatherSettingCmd.h"
#import "LGCurrentSportDataCmd.h"
#import "LGHistorySportDataCmd.h"
#import "LGHistorySleepDataCmd.h"
#import "LGHistoryHeartRateDataCmd.h"
#import "LGSportGoalsCmd.h"
#import "LGCleanUpSleepDataCmd.h"
#import "LGCleanUpSportDataCmd.h"
#import "LGCleanUpHeartRateDataCmd.h"
#import "LGHeartRateSampleIntervalCmd.h"
#import "LGScreenTimeCmd.h"
#import "LGScreenOrientationCmd.h"
#import "LGGPSSampleIntervalCmd.h"
#import "LGSleepSettingsCmd.h"
#import "LGSleepActionCmd.h"
#import "LGDistanceUnitCmd.h"
#import "LGTimeFormatCmd.h"
#import "LGCalendarEventCmd.h"
#import "LGFirmwareUpgradeCmd.h"
#import "LGContactsCmd.h"
#import "LGVolumeSettingCmd.h"
#import "LGMusicSongNameCmd.h"
#import "LGHeatControlsCmd.h"
#import "LGEnterCameraCmd.h"
#import "LGHistoryGPSDataCmd.h"
#import "LGCleanUpGPSDataCmd.h"
#import "LGTempUnitCmd.h"
#import "NSError+Peripheral.h"
#import "LGGPSInfoCmd.h"
#import "LGMapDataManager.h"
