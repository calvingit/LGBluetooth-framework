//
//  LGFunctionsController.m
//  LGBluetoothExample
//
//  Created by zhangwen on 16/7/20.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGFunctionsController.h"
#import "LGViewController.h"

@interface LGFunctionsController ()
@property (nonatomic, strong) NSArray *titles;
@end

@implementation LGFunctionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titles = @[@"功能测试", @"固件升级", @"写序列号"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReusableCellID"];
    UILabel *label = [cell viewWithTag:1];
    label.text = _titles[indexPath.row];
    label.font = [UIFont systemFontOfSize:24];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"PushDeviceSegue" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)path{
    if ([segue.identifier isEqualToString:@"PushDeviceSegue"]) {
        LGViewController *vc = (LGViewController *)segue.destinationViewController;
        vc.functionType = path.row;
    }
}

@end
