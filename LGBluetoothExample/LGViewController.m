//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) 2016 CLOUDTOO. All rights reserved.
//

#import "LGViewController.h"
#import "SVProgressHUD.h"
#import "LGCommandsViewController.h"
#import "LGFirmwareViewController.h"
#import "LGWriteSerialNumberController.h"
@import JDStatusBarNotification;
@import LGBluetooth;
#define kCellReuseIdentifier @"CellReuseIdentifier"

@import CoreBluetooth;
@interface LGViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) NSArray *peripherals;
@property (nonatomic, strong) NSArray *scanedPeripherals;
@end

@implementation LGViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralUpdateStateNotification:) name:kCBCentralManagerStateNotification object:nil];
        _peripherals = [NSMutableArray array];
    }
    return self;
}

- (void)centralUpdateStateNotification:(NSNotification *)notificaion{
    NSNumber *state = notificaion.object;
    
    if (state.boolValue) {
        [JDStatusBarNotification dismiss];
    }else{
        [JDStatusBarNotification showWithStatus:@"请打开蓝牙设置"];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem *scanButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(scanForPeripherals)];
    self.navigationItem.rightBarButtonItem = scanButtonItem;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"搜索设备";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    [self scanForPeripherals];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
}

//开始扫描
- (void)scanForPeripherals{
    [SVProgressHUD showWithStatus:@"扫描中...."];
    //获取已连接的设备，这些设备是不会广播的，所以不能通过scan来获取
    [[LGCentralManager sharedInstance] retrieveConnectedPeripheralsWithServices:@[kDefaultServiceUUID]];
    //开启扫描
    [[LGCentralManager sharedInstance] scanPeripheralsWithServices:@[kDefaultServiceUUID] interval:3 completion:^(LGCentralManager *manager, NSArray *scanedPeripherals) {
        self.scanedPeripherals = scanedPeripherals;
        self.peripherals = scanedPeripherals;
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
    
//    //开始扫描设备
//    [[LGCentralManager sharedInstance] scanPeripheralsWithServices:@[kDefaultServiceUUID]];
//    //扫描3秒钟
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //停止扫描, 如果不停止，将会一直扫描，占用资源。
//        [[LGCentralManager sharedInstance] stopScanForPeripherals];
//        //扫描结束之后，可以直接读取peripherals属性获取LGPeripheral对象
//        NSArray *scanedPeripherals = [LGCentralManager sharedInstance].peripherals;
//    });
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![searchText isEqualToString:@""]) {
        NSMutableArray *array = [NSMutableArray array];
        for (LGPeripheral *p in self.scanedPeripherals) {
            if ([p.name rangeOfString:searchText].length > 0) {
                [array addObject:p];
            }
        }
        self.peripherals = array;
        [self.tableView reloadData];
    }else{
        self.peripherals = self.scanedPeripherals;
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}


#pragma mark - UITableViewDataSource

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleInsert;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    LGPeripheral *p = self.peripherals[indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    nameLabel.text = p.name;
    
    UILabel *uuidLabel = (UILabel *)[cell.contentView viewWithTag:2];
    uuidLabel.text = p.UUIDString;
    
    UILabel *rssiLabel = (UILabel *)[cell.contentView viewWithTag:3];
    rssiLabel.text = [p.RSSI stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.navigationItem.rightBarButtonItem.enabled) {
        LGPeripheral *p = self.peripherals[indexPath.row];
        [SVProgressHUD showWithStatus:@"连接中"];
        [p connectWithTimeout:5 completion:^(LGPeripheral *peripheral, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:@"连接失败"];
            } else {
                [SVProgressHUD dismiss];
                if (self.functionType == 0) {
                    [self performSegueWithIdentifier:@"CommandsTestSegue" sender:peripheral];
                }else if (self.functionType == 1){
                    [self performSegueWithIdentifier:@"FirmwareUpgradeSegue" sender:peripheral];
                } else if (self.functionType == 2){
                    [self performSegueWithIdentifier:@"SerialNumberSegue" sender:peripheral];
                }
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CommandsTestSegue"]) {
        LGCommandsViewController *vc = segue.destinationViewController;
        vc.peripheral = sender;
    } else if([segue.identifier isEqualToString:@"FirmwareUpgradeSegue"]){
        LGFirmwareViewController *vc = segue.destinationViewController;
        vc.peripheral = sender;
    } else if([segue.identifier isEqualToString:@"SerialNumberSegue"]){
        LGWriteSerialNumberController *vc = segue.destinationViewController;
        vc.peripheral = sender;
    }
}

@end
