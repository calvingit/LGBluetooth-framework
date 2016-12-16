//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) zhangwen. All rights reserved.
//

#import "LGViewController.h"
#import "LGCommandsViewController.h"
#import "LGFirmwareViewController.h"
#import "LGWriteSerialNumberController.h"
#import "LGMapUpdateViewController.h"
@import JDStatusBarNotification;
@import LGBluetooth;
@import SVProgressHUD;
#define kCellReuseIdentifier @"CellReuseIdentifier"

@import CoreBluetooth;
@interface LGViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSMutableArray *allPeripherals;
@end

@implementation LGViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralUpdateStateNotification:) name:kCBCentralManagerStateNotification object:nil];
        _peripherals = [NSMutableArray array];
        _allPeripherals = [NSMutableArray array];
    }
    return self;
}

- (void)centralUpdateStateNotification:(NSNotification *)notificaion{
    LGCentralManager *manager = notificaion.object;
    
    if (manager.poweredOn) {
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
    [self.allPeripherals removeAllObjects];
    //获取已连接的设备，这些设备是不会广播的，所以不能通过scan来获取
    NSArray *connectedPeripherals = [[LGCentralManager sharedInstance] retrieveConnectedPeripheralsWithServices:@[kDefaultServiceUUID]];
    [self.allPeripherals addObjectsFromArray:connectedPeripherals];
    //开启扫描
    [[LGCentralManager sharedInstance] scanPeripheralsWithServices:nil interval:3 completion:^(LGCentralManager *manager, NSArray *scanedPeripherals) {
        [self.allPeripherals addObjectsFromArray:scanedPeripherals];
        [self filterPeripheralsWithText:nil];
        [SVProgressHUD dismiss];
    }];
}

// 搜索过滤
- (void)filterPeripheralsWithText:(NSString *)text{
    NSString *searchText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchText.length > 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (LGPeripheral *p in self.allPeripherals) {
            if ([p.name rangeOfString:searchText.uppercaseString].length > 0) {
                [array addObject:p];
            }
        }
        self.peripherals = array;
        [self.tableView reloadData];
    }else{
        self.peripherals = self.allPeripherals;
        [self.tableView reloadData];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterPeripheralsWithText:searchText];
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
                    [self performSegueWithIdentifier:@"MapUpdateSegue" sender:peripheral];
                } else if (self.functionType == 3){
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
    } else if([segue.identifier isEqualToString:@"MapUpdateSegue"]){
        LGMapUpdateViewController *vc = segue.destinationViewController;
        vc.peripheral = sender;
    }
}

@end
