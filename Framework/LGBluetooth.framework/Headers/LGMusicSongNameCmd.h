//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseSettingCommand.h"
/**
 *  同步当前播放中的歌曲名称
 */
@interface LGMusicSongNameCmd : LGBaseSettingCommand
@property (nonatomic, copy) NSString *songName;//歌名
@end
