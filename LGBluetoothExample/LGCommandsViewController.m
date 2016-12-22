//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 zhangwen. All rights reserved.
//

#import "LGCommandsViewController.h"
#import "LGContactsViewController.h"
#import "LGTextViewController.h"
@import SVProgressHUD;
@import JDStatusBarNotification;
@import LGBluetooth;
@import EventKit;

#define kDetailCellID  @"DetailCellID"
#define kShowTextSegueID @"ShowTextSegue"

@interface LGCommandsViewController ()<UITableViewDelegate, UITableViewDataSource, LGPeripheralAgentDelegate>
@property (strong, nonatomic) NSArray *commands;
@property (nonatomic, strong) LGPeripheralAgent *agent;
@end

@implementation LGCommandsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"功能命令";
    
    _commands = @[@"获取SN号", @"获取设备信息", @"设置个人信息", @"获取个人信息", @"设置时间", @"恢复出厂设置", @"获取配对码", @"确认配对码", @"设置久坐提醒", @"获取久坐提醒", @"增加事项提醒", @"删除事项提醒", @"修改事项提醒", @"清空事项提醒", @"读取事项提醒", @"设置通知开关", @"读取通知开关", @"获取当前运动数据", @"获取历史运动数据", @"清空历史运动数据", @"获取睡眠历史数据", @"清空睡眠历史数据", @"获取目标值", @"设置目标值", @"获取体征数据", @"清空体征数据", @"退出拍照界面", @"城市名设置", @"天气设置",@"设置心率采样间隔", @"获取心率采样间隔", @"设置背光时间", @"获取背光时间", @"设置屏幕方向", @"获取屏幕方向", @"设置GPS采样间隔", @"获取GPS采样间隔", @"设置预设睡眠", @"获取预设睡眠", @"进入睡眠", @"退出睡眠", @"设置长度单位",@"读取长度单位", @"设置时间格式",@"读取时间格式", @"清空日历", @"增加日历(系统的)",@"读取日历", @"进入固件升级模式", @"联系人电话本", @"增大音量", @"降低音量", @"同步歌名", @"进入拍照界面", @"获取Heat温度",@"设置Heat温度", @"读取GPS数据", @"清空GPS数据",@"读取温度单位", @"设置温度单位", @"读取GPS信息", @"读取高尔夫数据", @"清空高尔夫数据"];
    
    self.agent = [[LGPeripheralAgent alloc] initWithPeripheral:self.peripheral];
    self.agent.delegate = self;
    
    [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        style.barColor = [UIColor colorWithRed:0.193 green:0.622 blue:1.000 alpha:1.000];
        style.textColor = [UIColor whiteColor];
        return style;
    }];
}

- (void)switchHeartRateStatus:(UISwitch *)switchButton{
    [self.agent enableRealTimeHeartRateUpdate:switchButton.isOn completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showSuccessWithStatus:@"设置实时心率失败"];
            switchButton.on = !switchButton.on;
        } else {
            [SVProgressHUD showSuccessWithStatus:@"设置实时心率成功"];
        }
    }];
}
#pragma mark - LGPeripheralAgentDelegate

/**
 *  心率数据
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent heartRateUpdate:(NSInteger)heartRate{
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"心率:%ld", heartRate] dismissAfter:2];
}

/**
 *  相机控制操作
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent cameraControl:(LGCameraAction)cameraAction{
    NSString *title = @"";
    
    switch (cameraAction) {
        case LGCameraActionTakePicture: {
            title = @"拍照";
            break;
        }
        case LGCameraActionEnd: {
            title = @"退出拍照";
            break;
        }
        case LGCameraActionSwitchToFront: {
            title = @"切换前置摄像头";
            break;
        }
        case LGCameraActionSwitchToBack: {
            title = @"切换后置摄像头";
            break;
        }
    }
    
    [JDStatusBarNotification showWithStatus:title dismissAfter:2];
}

/**
 *  音乐控制操作
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent musicControl:(LGMusicAction)musicAction{
    NSString *title = @"";
    switch (musicAction) {
        case LGMusicActionPlay: {
            title = @"开始播放音乐";
            break;
        }
        case LGMusicActionPause: {
            title = @"停止播放音乐";
            break;
        }
        case LGMusicActionNext: {
            title = @"下一首歌";
            break;
        }
        case LGMusicActionPrevious: {
            title = @"上一首歌";
            break;
        }
        case LGMusicActionVolumeUp: {
            title = @"增加音量";
            break;
        }
        case LGMusicActionVolumeDown: {
            title = @"降低音量";
            break;
        }
    }
    [JDStatusBarNotification showWithStatus:title dismissAfter:1.5];
}

/**
 *  查找手机控制操作
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent findMobilePphone:(LGFindMobilePhoneAction)action{
    if (action == LGFindMobilePhoneActionStart) {
        [JDStatusBarNotification showWithStatus:@"开始查找手机" dismissAfter:1.5];
    }else{
        [JDStatusBarNotification showWithStatus:@"停止查找手机" dismissAfter:1.5];
    }
}

/**
 *  拨打电话号码
 */
- (void)peripheralAgent:(LGPeripheralAgent *)peripheralAgent dialingPhoneNumber:(NSString *)phoneNumber{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]]];
}

/**
 *  挂断电话
 */
- (void)peripheralAgentHangUpPhoneCall:(LGPeripheralAgent *)peripheralAgent{
    [JDStatusBarNotification showWithStatus:@"挂断电话" dismissAfter:1.5];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:kShowTextSegueID]) {
        LGTextViewController *vc =segue.destinationViewController;
        vc.text = sender;
    }
    [SVProgressHUD dismiss];
}

#pragma mark - UITableViewDataSource


-(void)showAlert:(NSString *)title msg:(NSString *)msg{
    [SVProgressHUD dismiss];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:action];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailCellID];
    
    NSString *p = [_commands objectAtIndex:indexPath.row];
    cell.textLabel.text = p;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [SVProgressHUD showWithStatus:@"同步中"];
    NSUInteger row = indexPath.row;
    if (row == 0) {
        LGSerialNumberCmd *cmd = [LGSerialNumberCmd commandWithAgent:self.agent];
        [[cmd readSNWithSuccess:^(NSString *string) {
            [self showAlert:_commands[row] msg:string];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }
    else if (row == 1){
        LGFirmwareInformationCmd *cmd = [LGFirmwareInformationCmd commandWithAgent:self.agent];
        [[cmd readFirmwareInformationWithSuccess:^(BOOL bindingStatus, NSInteger batteryPower, NSString *version) {
            [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"绑定状态:%@, 电量:%@%%, 版本:%@",
                                                @(bindingStatus), @(batteryPower), version]];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }
    else if (row == 2){
        LGUserInfo *info = [[LGUserInfo alloc] initWithGender:YES height:183 weight:89.45];
        
        LGUserInfoCmd *cmd = [LGUserInfoCmd commandWithAgent:self.agent] ;
        [[cmd setUserInfo:info success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
        
    }else if (row == 3){
        LGUserInfoCmd *cmd = [LGUserInfoCmd commandWithAgent:self.agent] ;
        [[cmd readUserInfoWithSuccess:^(LGUserInfo *userInfo) {
            [self showAlert:_commands[row] msg: userInfo.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
    }
    else if (row == 4){
        LGTimeSettingCmd *cmd = [[LGTimeSettingCmd alloc] initWithPeripheralAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
        
    }
    else if (row == 5){
        LGRestoreFactorySettingsCmd *cmd = [LGRestoreFactorySettingsCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }
    else if (row == 6){
        LGPairingCodeCmd *cmd = [LGPairingCodeCmd commandWithAgent:self.agent];
        [[cmd readCodeWithSuccess:^(NSString *string) {
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    } else if (row == 7){
        LGComfirmPairingCodeCmd *cmd = [LGComfirmPairingCodeCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }
    else if (row == 8){
        LGSedentaryReminder *reminder = [LGSedentaryReminder new];
        reminder.status = YES;
        reminder.beginTime = @"08:00";
        reminder.endTime = @"22:30";
        reminder.interval = 30;
        reminder.weekPeriod = LGWeekPeriodMonday | LGWeekPeriodTuesday | LGWeekPeriodWednesday;
        reminder.validSteps = 100;
        
        LGSedentaryReminderCmd *cmd = [LGSedentaryReminderCmd commandWithAgent:self.agent];
        [[cmd setReminder:reminder success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
        
    }else if (row == 9){
        LGSedentaryReminderCmd *cmd = [LGSedentaryReminderCmd commandWithAgent:self.agent];
        [[cmd readReminderWithSuccess:^(LGSedentaryReminder *reminder) {
            [self showAlert:_commands[row] msg: reminder.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
    }
    else if (row == 10){
        LGAlarmClock *clock = [LGAlarmClock new];
        clock.status = YES;
        clock.weekPeriod = LGWeekPeriodMonday | LGWeekPeriodTuesday;
        clock.time = @"06:54";
        clock.type = LGAlarmClockTypeSport;
        
        
        LGAlarmClockCmd *cmd = [[LGAlarmClockCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd addClock:clock success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    } else if (row == 11){
        
        LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent] deleteClockAtIndex:0 success:^{
            [self showAlert:_commands[row] msg: @"成功"];
            
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
        [cmd start];
        
    }else if (row == 12){
        LGAlarmClock *clock = [LGAlarmClock new];
        clock.status = YES;
        clock.weekPeriod = LGWeekPeriodMonday | LGWeekPeriodTuesday | LGWeekPeriodThursday;
        clock.time = @"14:36";
        clock.type = LGAlarmClockTypeSport;
        
        LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent]  changeClockAtIndex:0 withNewClock:clock success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
        [cmd start];
        
    }else if (row == 13){
        LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent]  cleanUpClocksWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
        [cmd start];
    }else if (row == 14){
        LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent]  readClocksWithSuccess:^(NSArray *array) {
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:kShowTextSegueID sender:array.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
        [cmd start];
    }
    else if(row == 15){
        LGNotificationSettings *settings = [LGNotificationSettings new];
        settings.calling = YES;
        settings.missedCall = YES;
        settings.SMS = YES;
        settings.email = YES;
        settings.social = YES;
        settings.calendar = YES;
        settings.antilost = YES;
        settings.powerSavingMode = YES;
        settings.heartRateAlarm = YES;
        
        LGNotificationsCmd *cmd = [[LGNotificationsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setNotifications:settings success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
        
    }else if (row == 16){
        LGNotificationsCmd *cmd = [[LGNotificationsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readNotificaitonSettingsWithSuccess:^(LGNotificationSettings *settings) {
            [self showAlert:_commands[row] msg: settings.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
    } 
    
    else if (row == 17){
        LGCurrentSportDataCmd *cmd = [LGCurrentSportDataCmd commandWithAgent:self.agent];
        [[cmd readCurrentSportDataWithSuccess:^(NSInteger steps, NSInteger calories) {
            [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"步数:%ld步\n卡路里:%ld卡", steps, calories]];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    else if (row == 18){
        LGHistorySportDataCmd *cmd = [[LGHistorySportDataCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readDataWithSuccess:^(NSArray<LGSportData *> *datas) {
            [self performSegueWithIdentifier:kShowTextSegueID sender:datas.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    else if (row == 19){
        LGCleanUpSportDataCmd *cmd = [LGCleanUpSportDataCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }
    else if (row == 20){
        
        LGHistorySleepDataCmd *cmd = [[LGHistorySleepDataCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readDataWithSuccess:^(NSArray<LGSleepData *> *datas) {
            [self performSegueWithIdentifier:kShowTextSegueID sender:datas.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
        
    } 
    
    else if (row == 21){
        LGCleanUpSleepDataCmd *cmd = [LGCleanUpSleepDataCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }
    else if (row == 22){
        LGSportGoalsCmd *cmd = [[LGSportGoalsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readGoalsWithSuccess:^(LGSportGoals *goals){
            [self showAlert:_commands[row] msg:goals.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
        
    } else if (row == 23){
        LGSportGoals *goals = [LGSportGoals new];
        goals.steps = 100000;
        goals.calory = 20000;
        goals.distance = 34455;
        LGSportGoalsCmd *cmd = [[LGSportGoalsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setGoals:goals success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
    }
    else if (row == 24){
        
        LGHistoryBodyDataCmd *cmd = [[LGHistoryBodyDataCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readDataWithSuccess:^(NSArray<LGBodyData *> *datas) {
            [self performSegueWithIdentifier:kShowTextSegueID sender:datas.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }] start];
        
    }
    
    else if (row == 25){
        LGCleanUpHeartRateDataCmd *cmd = [LGCleanUpHeartRateDataCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
        
    }
    else if (row == 26){
        LGQuitCameraCmd *cmd = [[LGQuitCameraCmd alloc] initWithPeripheralAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }
    else if (row == 27){
        LGWeatherSettingCmd *cmd = [LGWeatherSettingCmd commandWithAgent:self.agent];
        [cmd setCityName:@"香港特别行政区"];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }else if (row == 28){
        LGWeatherSettingCmd *cmd = [LGWeatherSettingCmd commandWithAgent:self.agent];
        [cmd setWeatherCode:LGWeatherCodeSunny lowestTemp:23 highestTemp:28];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg: error.localizedDescription];
        }];
    }
    else if (row == 29){
        LGHeartRateSampleIntervalCmd *cmd = [[LGHeartRateSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setInterval:10 success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }else if (row == 30){
        LGHeartRateSampleIntervalCmd *cmd = [[LGHeartRateSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readIntervalWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"间隔时间:%ld秒",integer]];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    else if (row == 31){
        LGScreenTimeCmd *cmd = [[LGScreenTimeCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setScreenTime:20 success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }else if (row == 32){
        LGScreenTimeCmd *cmd = [[LGScreenTimeCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readScreenTimeWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"亮屏时间是%ld秒", integer]];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }
    else if (row == 33){
        LGScreenOrientationCmd *cmd = [[LGScreenOrientationCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setOrientation:LGOrientationV success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }else if (row == 34){
        LGScreenOrientationCmd *cmd = [[LGScreenOrientationCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readOrientationWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg:integer ? @"竖屏":@"横屏"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    
    else if (row == 35){
        LGGPSSampleIntervalCmd *cmd = [[LGGPSSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setInterval:10 success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }else if (row == 36){
        LGGPSSampleIntervalCmd *cmd = [[LGGPSSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readIntervalWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"间隔时间:%ld秒",integer]];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    else if (row == 37){
        
        LGSleepSettings *settings = [LGSleepSettings new];
        settings.status = YES;
        settings.sleepTime = @"16:20";
        settings.wakeupTime = @"17:30";
        
        LGSleepSettingsCmd *cmd = [[LGSleepSettingsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd setSleepTime:settings success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    } else if (row == 38){
        LGSleepSettingsCmd *cmd = [[LGSleepSettingsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readSleepTimeWithSuccess:^(LGSleepSettings *sleepTime) {
            [self showAlert:_commands[row] msg:sleepTime.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }
    else if (row == 39){
        LGSleepActionCmd *cmd = [[LGSleepActionCmd alloc] initWithPeripheralAgent:self.agent];
        cmd.action = LGSleepActionEnter;
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }else if (row == 40){
        LGSleepActionCmd *cmd = [[LGSleepActionCmd alloc] initWithPeripheralAgent:self.agent];
        cmd.action = LGSleepActionQuit;
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }
    
    else if (row == 41){
        LGDistanceUnitCmd *cmd = [LGDistanceUnitCmd commandWithAgent:self.agent];
        [[cmd setUnit:LGDistanceUnitMI success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    } else if (row == 42){
        LGDistanceUnitCmd *cmd = [LGDistanceUnitCmd commandWithAgent:self.agent];
        [[cmd readUnitWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg: integer ? @"单位是英里":@"单位是千米"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    
    else if (row == 43){
        LGTimeFormatCmd *cmd = [LGTimeFormatCmd commandWithAgent:self.agent];
        [[cmd setTimeFormat:LGTimeFormat12 success:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }else if (row == 44){
        LGTimeFormatCmd *cmd = [LGTimeFormatCmd commandWithAgent:self.agent];
        [[cmd readTimeFormatWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg: integer ? @"12小时制":@"24小时制"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    
    else if (row == 45){
        [[[LGCalendarEventCmd commandWithAgent:self.agent]  cleanUpCalendarsWithSuccess:^{
            [self showAlert:_commands[row] msg: @"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }else if (row == 46){
        LGCommandsQueue *chainCommands = [[LGCommandsQueue alloc] init];
        chainCommands.peripheralAgent = self.agent;
        EKEventStore* store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSDate* startDate = [NSDate date];
                NSDate* endDate = [NSDate dateWithTimeInterval:3600 * 24 * 30 sinceDate:startDate];
                
                NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate
                                                                        endDate:endDate
                                                                      calendars:nil];
                
                NSArray *events = [store eventsMatchingPredicate:predicate];
                NSUInteger count = events.count > 5 ? 5: events.count;
                for (int i = 0; i < count; i++) {
                    EKEvent *event =  events[i];
                    LGCalendarEvent *ce = [[LGCalendarEvent alloc] initWithEKEvent:event atIndex:i];
                    
                    LGCalendarEventCmd *cmd = [[[LGCalendarEventCmd alloc] init] addCalendarEvent:ce success:nil failure:nil];
                    [chainCommands addCommandObject:cmd];
                }
                
                [chainCommands startWithCompletion:^(NSError *error){
                    [self showAlert:_commands[row] msg:error ? error.localizedDescription: @"成功"];
                }];
            }
        }];
    }  else if (row == 47){
        LGCalendarEventCmd *cmd = [[LGCalendarEventCmd commandWithAgent:self.agent]  readCalendarsSuccess:^(NSArray *array) {
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:kShowTextSegueID sender:array.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        [cmd start];
    }
    
    else if (row == 48){
        LGFirmwareUpgradeCmd *cmd = [LGFirmwareUpgradeCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }
    
    else if (row == 49){
        LGContactsViewController *vc = [[LGContactsViewController alloc] init];
        vc.agent = self.agent;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 50){
        LGVolumeSettingCmd *cmd = [LGVolumeSettingCmd commandWithAgent:self.agent];
        cmd.action = LGVolumeUpAction;
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        
    } else if (row == 51){
        LGVolumeSettingCmd *cmd = [LGVolumeSettingCmd commandWithAgent:self.agent];
        cmd.action = LGVolumeDownAction;
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }
    else if (row == 52){
        LGMusicSongNameCmd *cmd = [[LGMusicSongNameCmd alloc] initWithPeripheralAgent:self.agent];
        cmd.songName = @"同一首歌";
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }
    else if (row == 53){
        LGEnterCameraCmd *cmd = [[LGEnterCameraCmd alloc] initWithPeripheralAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }
    else if (row == 54){
        LGHeatControlsCmd *cmd = [[LGHeatControlsCmd alloc] initWithPeripheralAgent:self.agent];
        [cmd readAllHeatLevelsWithSuccess:^(NSDictionary *dict) {
            [self showAlert:_commands[row] msg:dict.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        [cmd start];
    }
    else if (row == 55){
        LGHeatControlsCmd *cmd = [[LGHeatControlsCmd alloc] initWithPeripheralAgent:self.agent];
        [cmd setLevel:LGHeatLevelTwo bodyPart:LGBodyPartShoulder success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        [cmd start];
    }
    else if (row == 56){
        LGHistoryGPSDataCmd *cmd = [[LGHistoryGPSDataCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd readDataWithSuccess:^(NSArray<LGGPSData *> *datas) {
            [self performSegueWithIdentifier:kShowTextSegueID sender:datas.description];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    else if (row == 57){
        LGCleanUpGPSDataCmd *cmd = [LGCleanUpGPSDataCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
    }
    else if (row == 58) {
        LGTempUnitCmd *cmd = [LGTempUnitCmd commandWithAgent:self.agent];
        [[cmd readUnitWithSuccess:^(NSInteger integer) {
            [self showAlert:_commands[row] msg:integer ? @"华氏度" : @"摄氏度"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
    }
    else if (row == 59) {
        LGTempUnitCmd *cmd = [LGTempUnitCmd commandWithAgent:self.agent];
        [[cmd setUnit:LGTempUnitFahrenheit success:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }] start];
        
    }
    else if (row == 60){
        LGGPSInfoCmd *cmd = [LGGPSInfoCmd commandWithAgent:self.agent];
        [cmd readInfoWithSuccess:^(NSData *data) {
            NSLog(@"GPS Info:%@", data);
            [SVProgressHUD dismiss];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        [cmd start];
    }
    
    else if (row == 61) {
        LGGolfScoresCmd *cmd = [LGGolfScoresCmd commandWithAgent:self.agent];
        [cmd readScoresWithSuccess:^(NSArray<LGGolfScore *> *scores) {
            NSLog(@"Golf Scores:%@", scores);
            [SVProgressHUD dismiss];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        [cmd start];
    }
    else if (row == 62) {
        LGCleanUpGolfDataCmd *cmd = [LGCleanUpGolfDataCmd commandWithAgent:self.agent];
        [cmd startWithSuccess:^{
            [self showAlert:_commands[row] msg:@"成功"];
        } failure:^(NSError *error) {
            [self showAlert:_commands[row] msg:error.localizedDescription];
        }];
        [cmd start];
    }
    else {
        [SVProgressHUD dismiss];
    }
}


@end
