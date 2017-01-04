//
//  LGGolfScoresCmd.h
//  LGBluetooth
//
//  Created by zhangwen on 2016/12/22.
//  Copyright © 2016年 zhangwen. All rights reserved.
//

#import "LGBaseCommand.h"

@class LGGolfScore;
@class LGParScore;

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
//日期(测试阶段有可能为空)
@property (nonatomic, strong) NSDate *date;
//记分
@property (nonatomic, copy) NSArray<LGParScore *> *scores;
//球场名字
@property (nonatomic, copy) NSString *courseName;
@end


/**
 记分
 */
@interface LGParScore : NSObject
//杆数Par
@property (nonatomic, assign) NSInteger par;
//分数score
@property (nonatomic, assign) NSInteger score;
@end
