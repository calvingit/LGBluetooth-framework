//
//  LGWriteSerialNumberController.m
//  LGBluetoothExample
//
//  Created by zhangwen on 16/7/20.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGWriteSerialNumberController.h"
@import LGBluetooth;
@import SVProgressHUD;
@interface LGWriteSerialNumberController ()

@property (weak, nonatomic) IBOutlet UITextField *manufacturerTextField;
@property (weak, nonatomic) IBOutlet UITextField *productCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *produceDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (nonatomic, strong) LGPeripheralAgent *agent;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation LGWriteSerialNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.agent = [[LGPeripheralAgent alloc] initWithPeripheral:self.peripheral];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"yyyyMMdd";
    
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    rec.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:rec];
}

- (void)hideKeyBoard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getSN{
    NSInteger ID = _idTextField.text.integerValue;
    if (ID > 35937) {
        ID = 35937;
    }

    NSDate *date = [self.formatter dateFromString:_produceDateTextField.text];
    return [LGSerialNumberCmd snWithManufacturer:_manufacturerTextField.text
                                     productCode:_productCodeTextField.text
                                            date:date
                                              ID:ID];
}
- (IBAction)nowAction:(id)sender {
    _produceDateTextField.text = [self.formatter stringFromDate:[NSDate date]];
}
- (IBAction)previewAction:(id)sender {
    _previewLabel.text = [self getSN];
}
- (IBAction)syncAction:(id)sender {
    NSString *sn = [self getSN];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否写入下面的序列号" message:sn preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *syncAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LGSerialNumberCmd *cmd = [LGSerialNumberCmd commandWithAgent:self.agent];
        [SVProgressHUD showWithStatus:@"正在写号中..."];
        [[cmd setSN:sn success:^{
            [SVProgressHUD showSuccessWithStatus:@"写入成功"];
        } failure:^(NSError *error) {
            [SVProgressHUD showSuccessWithStatus:@"写入失败"];
        }] start];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:syncAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
