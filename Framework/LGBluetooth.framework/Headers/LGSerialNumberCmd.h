//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGBaseCommand.h"



/**
 *   序列号(sn)编码规则如下:
 1、序列号用于识别产品类型、年限、生产商等用途。
 2、编码由阿拉伯数字和英文字母组成(9 个数字,24 个字母);其中阿拉伯数字1~9(0 除外),英文 字母大写A~Z(I、O 除外);即:123456789ABCDEFGHJKLMNPQRSTUVWXYZ 。
 3、共33个字符表示全区编码,以1 开始,Z 结束。即组成33进制数据。
 编码区代码格式共 13位可见字符。格式规定如下:
 - 生产商(3 位) PPP
 - 产品/供应商归类码(3位) CCC
 - 年份(1位) Y
 - 周数(2 位) WW
 - 周数内天数(1 位) D
 - ID 号(3 位) AAA
 
 如:YTW11111N711D
 PPP:供应商名字( 生产商为YTW) CCC:产品/供应商归类码,主要用于产品的统一和归类扩展用(111 为相应归类码) Y:年份从2015 年开始为1,即34 年循环一次( 1 为2015 年生产) WW:一年内的周数(1N为第22 周生产)
 D:一周内的天数,周一为1,周日为7 (7为周日生产)
 AAA:生产的ID号( 11D为相应产品ID号)
 */
@interface LGSerialNumberCmd : LGBaseCommand

///读取
- (instancetype)readSNWithSuccess:(LGBlockWithString)success failure:(LGBlockWithError)failure;

//写入新的序列号，13位，如“YTB11N7111D11”
//请勿随意使用这个功能，如果设置成功，请到蓝牙设置列表里面忽略已连接的设备。
- (instancetype)setSN:(NSString *)sn success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

@end




