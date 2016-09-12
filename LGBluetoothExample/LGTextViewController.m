//
//  LGTextViewController.m
//  LGBluetoothExample
//
//  Created by zhangwen on 16/8/31.
//  Copyright © 2016年 CLOUDTOO. All rights reserved.
//

#import "LGTextViewController.h"

@interface LGTextViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation LGTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = self.text;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.textView.contentSize = CGSizeMake(1000, 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
