//
// LGBluetooth
//
// Created by : zhangwen
// Copyright (C) zhangwen. All rights reserved.
//

#import "LGContactsViewController.h"
@import LGBluetooth;
@import SVProgressHUD;
@import AddressBook;
@import AddressBookUI;

static NSString *const kCellId = @"kCellId";

@interface LGContactsViewController ()<ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *contacts;
@end

@implementation LGContactsViewController

- (instancetype)init{
    if (self = [super init]) {
        _contacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *cleanupButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cleanUpContacts)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact)];
    self.navigationItem.rightBarButtonItems = @[cleanupButton, addButton];
    
    [SVProgressHUD showWithStatus:@"同步联系人。。。"];
    LGContactsCmd *cmd = [[LGContactsCmd alloc] initWithPeripheralAgent:self.agent];
    [[cmd readContactsWithSuccess:^(NSArray *array) {
        [SVProgressHUD dismiss];
        [self.contacts addObjectsFromArray:array];
        [self.contacts sortUsingComparator:^NSComparisonResult(LGContact *obj1, LGContact * obj2) {
            return obj1.index > obj2.index;
        }];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.description];
    }] start];
}

- (void)cleanUpContacts{
    [SVProgressHUD showWithStatus:@"清空联系人。。。"];
    LGContactsCmd *cmd = [[LGContactsCmd alloc] initWithPeripheralAgent:self.agent];
    [[cmd cleanUpContactsWithSuccess:^{
        [SVProgressHUD showSuccessWithStatus:@"成功"];
        [self.contacts removeAllObjects];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.description];
    }] start];
}

- (void)addContact{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)stringByRemovingNotDdecimal:(NSString *)str{
    NSString *result = @"";
    for (int i=0; i<str.length; i++) {
        NSString *s=[str substringWithRange:NSMakeRange(i, 1)];
        const char *ch=[s UTF8String];
        
        if (*ch>='0'&& *ch<='9') {
            result=[result stringByAppendingString:s];
        }
    }
    return result;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellId];
    }
    LGContact *contact = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.phoneNumber;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否删除联系人" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"删除联系人..."];
        LGContact *contact = [self.contacts objectAtIndex:indexPath.row];
        LGContactsCmd *cmd = [[LGContactsCmd alloc] initWithPeripheralAgent:self.agent];
        [[cmd deleteContactAtIndex:contact.index success:^{
            [self.contacts removeObject:contact];
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"删除联系人成功"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"删除联系人失败"];
            
        }] start];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertVC addAction:action];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
// Called after a person has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)recordRef NS_AVAILABLE_IOS(8_0){
    //取得记录中得信息
    NSString *firstName=(__bridge NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);//注意这里进行了强转，不用自己释放资源
    NSString *lastName=(__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    
    ABMultiValueRef phoneNumbersRef= ABRecordCopyValue(recordRef, kABPersonPhoneProperty);//获取手机号，注意手机号是ABMultiValueRef类，有可能有多条
    NSArray *phoneNumbers=(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumbersRef);//取得CFArraryRef类型的手机记录并转化为NSArrary
    //long count= ABMultiValueGetCount(phoneNumbersRef);
    
    NSString *name =[NSString stringWithFormat:@"%@%@",lastName ? :@"",firstName ? :@""];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *number = phoneNumbers.firstObject;
    number = [self stringByRemovingNotDdecimal:number];
    
    NSInteger index = self.contacts.count;
    if(self.contacts.count < 10){
        [SVProgressHUD showWithStatus:@"添加联系人..."];
        //号码命令
        LGContactsCmd *numberCmd = [LGContactsCmd new];
        [numberCmd addContactPhoneNumber:number index:index success:nil failure:nil];
        //姓名命令
        LGContactsCmd *nameCmd = [LGContactsCmd new];
        [nameCmd addContactName:name index:index success:nil failure:nil];
        
        //两条连续的命令可以放在队列里面
        LGCommandsQueue *queque = [LGCommandsQueue new];
        queque.peripheralAgent = self.agent;
        [queque addCommandObject:numberCmd];
        [queque addCommandObject:nameCmd];
        [queque startWithCompletion:^(NSError *error) {
            if(error){
                [SVProgressHUD showErrorWithStatus:error.description];
            }else{
                LGContact *contact = [[LGContact alloc] init];
                contact.index = index;
                contact.name = name;
                contact.phoneNumber = number;
                [self.contacts addObject:contact];
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }
        }];
    }
}

// Called after a property has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_AVAILABLE_IOS(8_0){
    
}

// Called after the user has pressed cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    
}


// Deprecated, use predicateForSelectionOfPerson and/or -peoplePickerNavigationController:didSelectPerson: instead.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person NS_DEPRECATED_IOS(2_0, 8_0){
    return YES;
}

// Deprecated, use predicateForSelectionOfProperty and/or -peoplePickerNavigationController:didSelectPerson:property:identifier: instead.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_DEPRECATED_IOS(2_0, 8_0){
    return YES;
}
@end
