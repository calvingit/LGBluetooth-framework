//
//  LGFirmwareViewController.m
//  LGBluetoothExample
//
//  Created by zhangwen on 16/7/20.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGFirmwareViewController.h"
#import "LGDFUManager.h"
@import LGBluetooth;
@import iOSDFULibrary;
@import SVProgressHUD;

@interface LGFirmwareViewController ()<LGDFUManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@property (nonatomic, strong) NSArray *files;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) LGDFUManager *dfuManager;
@end

@implementation LGFirmwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.peripheral.name;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateFiles)];
    self.navigationItem.rightBarButtonItem = button;
    
    [self updateFiles];
    
    LGPeripheralAgent *agent = [[LGPeripheralAgent alloc] initWithPeripheral:self.peripheral];
    self.dfuManager = [[LGDFUManager alloc] initWithPeripheralAgent:agent];
}

- (void)updateFiles{
    self.files = [self getZipFilesFromDocumentDirectory];
    self.selectedIndex = -1;
    [self.tableView reloadData];
}

-(NSArray *)getZipFilesFromDocumentDirectory
{
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSMutableArray *zipFilesNames = [[NSMutableArray alloc]init];
    NSError *error;
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    if (error)
    {
        NSLog(@"error in opening directory path: %@",directoryPath);
        return nil;
    }
    else
    {
        for (NSString *fileName in fileNames)
        {
            if ([self checkFileExtension:fileName fileExtension:@"zip"])
            {
                [zipFilesNames addObject:fileName];
            }
        }
        return [zipFilesNames copy];
    }
}

-(BOOL)checkFileExtension:(NSString *)fileName fileExtension:(NSString*)fileExtension
{
    NSString *extension = [[fileName pathExtension] lowercaseString];
    return [extension isEqualToString:fileExtension];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)updateAction:(id)sender {
    if (self.selectedIndex < 0) {
        [SVProgressHUD showErrorWithStatus:@"请先选择文件\n如果未出现固件文件，请点击右上角按钮刷新"];
        return;
    }
    
    self.updateButton.enabled = NO;
    [SVProgressHUD showWithStatus:@"升级准备中"];
    
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:self.files[self.selectedIndex]];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    
    self.dfuManager.delegate = self;
    [self.dfuManager startWithfileURL:fileURL];
    
}

#pragma mark - LGDFUManagerDelegate

- (void)DFUManagerEnterUpgradeMode:(LGDFUManager *)manager{
    [SVProgressHUD showWithStatus:@"进入升级模式成功"];
}

- (void)DFUManagerStarting:(LGDFUManager *)manager{
    [SVProgressHUD showWithStatus:@"升级开始"];
}

- (void)DFUManager:(LGDFUManager *)manager onUploadProgress:(NSInteger)progress{
    [SVProgressHUD showProgress:progress*1.0f/100.0 status:[NSString stringWithFormat:@"%ld%%", progress]];
}

- (void)DFUManagerCompleted:(LGDFUManager *)manager{
    [SVProgressHUD showSuccessWithStatus:@"升级完成"];
    self.updateButton.enabled = YES;
}

- (void)DFUManager:(LGDFUManager *)manager didErrorOccurWithMessage:(NSString *)message{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"升级错误:%@", message]];
    self.updateButton.enabled = YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCellID"];
    cell.textLabel.text = self.files[indexPath.row];
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
    
}

@end
