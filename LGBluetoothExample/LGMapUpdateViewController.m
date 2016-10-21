//
//  LGMapUpdateViewController.m
//  LGBluetoothExample
//
//  Created by zhangwen on 2016/10/11.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGMapUpdateViewController.h"


@import SVProgressHUD;

@interface LGMapUpdateViewController ()<LGMapDataManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) LGMapDataManager *manager;
@property (nonatomic, strong) NSArray *fileNames;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) IBOutlet UILabel *tipsLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation LGMapUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *updateItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(updateFiles)];
    self.navigationItem.rightBarButtonItem = updateItem;
    [self updateFiles];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 进入后台弹出通知
-(void)appDidEnterBackground:(NSNotification *)_notification{
    // Controller is set when the DFU is in progress
    if (self.manager){
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
        }
        
        [self showLocalNotificationWithMessage:@"正在升级地图, 请勿远离设备"];
    }
}

//进入前台取消通知
-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

// 显示本地通知
- (void)showLocalNotificationWithMessage:(NSString *)message{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertAction = @"通知";
    notification.alertBody = message;
    notification.hasAction = NO;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone  defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

//刷新文档目录
- (void)updateFiles{
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    self.fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    self.selectedIndex = -1;
    self.tipsLabel.text = @"";
    [self.tableView reloadData];
}

//完整路径
- (NSString *)fullPathWithFileName:(NSString *)fileName{
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

//开始升级
- (IBAction)startAction:(id)sender {
    if (self.selectedIndex > -1) {
        
        [self.manager startUpdating];
        [SVProgressHUD showWithStatus:@"正在进入升级模式"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        self.tipsLabel.text = [NSString stringWithFormat:@"开始时间:%@", [formatter stringFromDate:[NSDate date]]];
    }else{
        [SVProgressHUD showInfoWithStatus:@"未选择文件"];
    }
}

//手动退出
- (IBAction)stopAction:(id)sender{
    [self.manager stopUpdatingForTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCellID"];
    cell.textLabel.text = self.fileNames[indexPath.row];
    
    NSString *filePath = [self fullPathWithFileName:self.fileNames[indexPath.row]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@字节", @(data.length)];
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    [tableView deselectRowAtIndexPath:oldIndexPath animated:YES];
    
    if (self.selectedIndex == indexPath.row) {
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell = [tableView cellForRowAtIndexPath:oldIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    self.selectedIndex = indexPath.row;
    
    NSString *filePath = [self fullPathWithFileName:self.fileNames[self.selectedIndex]];
    
    self.manager = [[LGMapDataManager alloc] initWithFileUrl:filePath peripheral:self.peripheral];
    self.manager.delegate = self;
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    self.tipsLabel.text = [NSString stringWithFormat:@"预计升级过程花费%ld分钟左右", data.length/2046/60];
}

#pragma mark - LGMapDataManagerDelegate

- (void)enterUpdatingMode{
    [SVProgressHUD showWithStatus:@"进入升级模式成功"];
}

- (void)updatingSuccessful{
    [SVProgressHUD dismiss];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [self showLocalNotificationWithMessage:@"升级地图成功"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"升级完成" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}
- (void)updatingProgress:(float)progress{
    [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"%.2f%%\n正在更新...", progress*100]];
}

- (void)interupteWithErrorType:(LGMapErrorType)errorType message:(NSString *)message{
    [SVProgressHUD dismiss];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [self showLocalNotificationWithMessage:[NSString stringWithFormat:@"错误代码:%@, %@", @(errorType),message]];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"错误代码:%@", @(errorType)] message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}
@end
