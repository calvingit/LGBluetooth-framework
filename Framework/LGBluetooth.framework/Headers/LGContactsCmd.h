//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

/**
 *  联系人电话本管理。一个完成的联系方式包含电话号码和姓名，分两次发送数据，先发电话号码。如果联系人只有号码没有姓名，
 *  则不需要发送姓名。
 *  注意：只适用于YTB003等带有通话功能的手环
 *
 */
@interface LGContactsCmd : LGBaseCommand
/**
 *  同步联系人电话号码 (主要)
 *
 *  @param phoneNumber 电话号码
 *  @param index       索引
 *
 */
- (instancetype)addContactPhoneNumber:(NSString *)phoneNumber index:(NSInteger)index success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  同步联系人姓名 (次要)
 *
 *  @param name  姓名
 *  @param index 索引
 *
 */
- (instancetype)addContactName:(NSString *)name index:(NSInteger)index success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  删除联系人（包括姓名和电话号码）
 *
 *  @param index 索引
 *
 */
- (instancetype)deleteContactAtIndex:(NSInteger)index success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  清空联系人
 *
 */
- (instancetype)cleanUpContactsWithSuccess:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;

/**
 *  读取联系人, NSArray (LGContact)
 *
 */
- (instancetype)readContactsWithSuccess:(LGBlockWithArray)success failure:(LGBlockWithError)failure;

@end

/**
 *  联系人
 */
@interface LGContact : NSObject
/**
 *  索引
 */
@property (nonatomic, assign) NSInteger index;
/**
 *  电话号码
 */
@property (nonatomic, copy) NSString *phoneNumber;
/**
 *  姓名
 */
@property (nonatomic, copy) NSString *name;
@end

