//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseSettingCommand.h"

///天气代码
typedef NS_ENUM(NSInteger, LGWeatherCode){
    LGWeatherCodeSunny         = 1,///晴天
    LGWeatherCodeCloudy        = 2,///多云
    LGWeatherCodeEveningCloudy = 3,///晚间多云
    LGWeatherCodeLightRain     = 4,///小雨
    LGWeatherCodeHeavyRain     = 5,///大雨
    LGWeatherCodeRainToSunny   = 6,///雨转晴
    LGWeatherCodeSnowDay       = 7,///雪天
    LGWeatherCodeThunderstorms = 8,///雷阵雨
    LGWeatherCodeHeavySnow     = 9,///大雪
};

/**
 *  天气相关设置，城市名称和温度只能同时设置一个，如果都要设置，请分别发送两个LGWeatherSettingCmd
 */
@interface LGWeatherSettingCmd : LGBaseSettingCommand
/**
 *  同步当前的城市名称到设备
 *
 *  @param name 城市名称, 20个字符
 *
 */
- (void)setCityName:(NSString *)name;

/**
 *  设置温度
 *
 *  @param code        天气代码，32:天晴, 26:阴天, 36:热
 *  @param lowestTemp  最低气温
 *  @param highestTemp 最高气温
 *
 */
- (void)setWeatherCode:(LGWeatherCode)code lowestTemp:(NSInteger)lowestTemp highestTemp:(NSInteger)highestTemp;
@end
