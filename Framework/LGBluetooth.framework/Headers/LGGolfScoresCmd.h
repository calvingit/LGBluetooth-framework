//
//  LGGolfScoresCmd.h
//  LGBluetooth
//
//  Created by zhangwen on 2016/12/22.
//  Copyright © 2016年 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGGolfScore;

/**
 高尔夫数据回调
 */
typedef void(^LGGolfScoresCmdBlock)(NSArray<LGGolfScore *> *scores);


/**
 读取所有高尔夫分数
 */
@interface LGGolfScoresCmd : LGBaseCommand

- (instancetype)readScoresWithSuccess:(LGGolfScoresCmdBlock)success failure:(LGBlockWithError)failure;

@end


/**
 高尔夫分数数据
 */
@interface LGGolfScore : NSObject
//日期
@property (nonatomic, strong) NSDate *date;
//记分，数组子项为字典，key是杆数，value是分数
@property (nonatomic, copy) NSArray<NSDictionary *> *scores;
//球场名字
@property (nonatomic, copy) NSString *courseName;
@end
