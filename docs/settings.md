# 用户信息（LGUserInfoCmd）
卡路里、距离计算需要用到用户的身高、体重、性别， 用`LGUserInfo`来表示:
- gender BOOL变量，男是NO，女是YES
- height 身高，cm单位
- weight 体重，kg单位，浮点数，精确到2位小数

设置用户信息:
```
LGUserInfo *info = [[LGUserInfo alloc] initWithGender:YES height:183 weight:89.45];

LGUserInfoCmd *cmd = [LGUserInfoCmd commandWithAgent:self.agent] ;
[[cmd setUserInfo:info success:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}] start];
```
读取用户信息:
```
LGUserInfoCmd *cmd = [LGUserInfoCmd commandWithAgent:self.agent] ;
[[cmd readUserInfoWithSuccess:^(LGUserInfo *userInfo) {
    [self showAlert:_commands[row] msg: userInfo.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}] start];
```

# 事项提醒(LGAlarmClockCmd)
事项提醒类似于iOS的闹钟功能，最多只能设置10个事项提醒。

使用类`LGAlarmClock`来表示，有以下几个属性:
- index 索引，唯一性，读取时会返回，添加提醒时可以忽略设置
- status 是否开启
- time 时间，如"08:30"
- type 提醒类型
- weekPeriod  周期

`type`是`LGAlarmClockType`枚举值，有很多种:
- LGAlarmClockTypeSport 运动
- LGAlarmClockTypeSleep 睡觉
- LGAlarmClockTypeEat 吃饭
- LGAlarmClockTypeMedicine 吃药
- LGAlarmClockTypeWakeup 醒来
- LGAlarmClockTypeMeeting 开会
- LGAlarmClockTypeUserDefined 自定义

`weekPeriod`是`LGWeekPeriod`类型，用法如：
- **星期一到星期三**表示为`LGWeekPeriodMonday | LGWeekPeriodTuesday | LGWeekPeriodWednesday`
- **周末**表示为`LGWeekPeriodSaturday | LGWeekPeriodSunday`

事项提醒有增删改查等操作，都是通过类`LGAlarmClockCmd`来完成，`LGAlarmClockCmd`的所有操作如下:

```
//读取
- (instancetype)readClocksWithSuccess:(LGBlockWithArray)success failure:(LGBlockWithError)failure;
//清空
- (instancetype)cleanUpClocksWithSuccess:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
//添加
- (instancetype)addClock:(LGAlarmClock *)clock success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
//修改
- (instancetype)changeClockAtIndex:(NSInteger)index withNewClock:(LGAlarmClock *)clock success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
//删除
- (instancetype)deleteClockAtIndex:(NSInteger)index success:(LGBlockWithVoid)success failure:(LGBlockWithError)failure;
```
## 增加提醒
```
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
```

## 删除提醒
```
LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent] deleteClockAtIndex:0 success:^{
    [self showAlert:_commands[row] msg: @"成功"];

} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.localizedDescription];
}];
[cmd start];
```

## 修改提醒
```
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
```

## 读取提醒
```
LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent]  readClocksWithSuccess:^(NSArray *array) {
    [SVProgressHUD dismiss];
    [self performSegueWithIdentifier:kShowTextSegueID sender:array.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.localizedDescription];
}];
[cmd start];
```

## 清空提醒
```
LGAlarmClockCmd *cmd = [[LGAlarmClockCmd commandWithAgent:self.agent]  cleanUpClocksWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.localizedDescription];
}];
[cmd start];
```

# 日历事件(LGCalendarEventCmd)
使用`LGCalendarEvent`来表示，有3个属性:
- index 索引
- date  日期
- content 内容

可以自定义上面几个参数，但更普遍的做法是读取系统日历事件，使用**EventKit.framework**。

初始化可以选择`EKEvent` + `index`:
```
- (instancetype)initWithEKEvent:(EKEvent *)event atIndex:(NSInteger)index;

```

`LGCalendarEventCmd`类对`LGCalendarEvent`进行操作。
## 添加日历事件
最多5个日历事件，即`index`最大为4。

下面代码演示了将系统日历同步到设备，其中使用了`LGCommandsQueue`，批量同步5个日历事件:
```
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
              [self showAlert:_commands[row] msg:error ? error.description: @"成功"];
          }];
      }
  }];

```

## 读取日历事件
只能读取索引和时间，不能读取`content`，可用于确认是否真的把日历事件写入设备中。

使用方法如下:
```
LGCalendarEventCmd *cmd = [[LGCalendarEventCmd commandWithAgent:self.agent]  readCalendarsSuccess:^(NSArray *array) {
    [SVProgressHUD dismiss];
    [self performSegueWithIdentifier:kShowTextSegueID sender:array.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}];
[cmd start];
```

## 清空日历事件
使用方法如下:
```
[[[LGCalendarEventCmd commandWithAgent:self.agent]  cleanUpCalendarsWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

# 距离单位(LGDistanceUnitCmd)
距离单位有两种:
- LGDistanceUnitKM 千米
- LGDistanceUnitMI  英里

设置距离单位：
```
LGDistanceUnitCmd *cmd = [LGDistanceUnitCmd commandWithAgent:self.agent];
[[cmd setUnit:LGDistanceUnitMI success:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

读取距离单位:
```
LGDistanceUnitCmd *cmd = [LGDistanceUnitCmd commandWithAgent:self.agent];
[[cmd readUnitWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg: integer ? @"单位是英里":@"单位是千米"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];

```
# GPS采样间隔(LGGPSSampleIntervalCmd)
GPS采样间隔是指隔多长时间读取一下当前的GPS位置，间隔越短，耗电越多。

单位为秒，最大一个字节大小，即255。

设置间隔时间:
```
//设置10秒钟
LGGPSSampleIntervalCmd *cmd = [[LGGPSSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd setInterval:10 success:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];

```

读取间隔时间:
```
LGGPSSampleIntervalCmd *cmd = [[LGGPSSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readIntervalWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"间隔时间:%ld秒",integer]];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];

```

# 心率采样间隔(LGHeartRateSampleIntervalCmd)
心率采样间隔是指隔多长时间读取一下当前的心率值，间隔越短，耗电越多，单位为秒。

单位为秒，最大一个字节大小，即255。

这个设置不影响实时心率设置，因为实时心率是蓝牙标准协议，每秒一个。

设置间隔时间:
```
LGHeartRateSampleIntervalCmd *cmd = [[LGHeartRateSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd setInterval:10 success:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

读取间隔时间:
```
LGHeartRateSampleIntervalCmd *cmd = [[LGHeartRateSampleIntervalCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readIntervalWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"间隔时间:%ld秒",integer]];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];

```

# 相机控制界面
`LGEnterCameraCmd`让设备进入相机控制界面：
```
LGEnterCameraCmd *cmd = [[LGEnterCameraCmd alloc] initWithPeripheralAgent:self.agent];
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}];

```

`LGQuitCameraCmd`让设备退出相机控制界面：
```
LGQuitCameraCmd *cmd = [[LGQuitCameraCmd alloc] initWithPeripheralAgent:self.agent];
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}];
```

# 同步歌名(LGMusicSongNameCmd)
可以将当前系统播放的歌名同步给设备，使用类`LGMusicSongNameCmd`来操作，它只有一个属性`songName`。
```
LGMusicSongNameCmd *cmd = [[LGMusicSongNameCmd alloc] initWithPeripheralAgent:self.agent];
cmd.songName = @"同一首歌";
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}];

```

# 推送通知开关
`LGNotificationSettings`类表示，有很多开关设置，都是`BOOL`属性:
- calling 来电
- missedCall 未接来电
- SMS 短信
- email 邮件
- social 社交App通知
- calendar 日历事件。关闭之后，`LGCalendarEventCmd`设置的不响应。
- powerSavingMode 省电模式。开启之后，不再震动提醒。
- antilost 防丢。蓝牙断开一段时间将震动
- heartRateAlarm 心率报警

设置推送通知开关：
```
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

```

读取推送通知开关:
```
LGNotificationsCmd *cmd = [[LGNotificationsCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readNotificaitonSettingsWithSuccess:^(LGNotificationSettings *settings) {
    [self showAlert:_commands[row] msg: settings.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.localizedDescription];
}] start];
```

# 屏幕显示方向(LGScreenOrientationCmd)
主要有横屏和竖屏两种:
- LGOrientationH 横屏
- LGOrientationV 竖屏

设置屏幕方向:
```
LGScreenOrientationCmd *cmd = [[LGScreenOrientationCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd setOrientation:LGOrientationV success:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];

```

读取屏幕方向:
```
LGScreenOrientationCmd *cmd = [[LGScreenOrientationCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readOrientationWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg:integer ? @"竖屏":@"横屏"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];

```

# 亮屏时间 (LGScreenTimeCmd)
亮屏时间指用户不操作屏幕时，多长时间自动关闭屏幕，单位为秒。

设置亮屏时间:
```
LGScreenTimeCmd *cmd = [[LGScreenTimeCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd setScreenTime:20 success:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

读取亮屏时间:
```
LGScreenTimeCmd *cmd = [[LGScreenTimeCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readScreenTimeWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg:[NSString stringWithFormat:@"亮屏时间是%ld秒", integer]];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

# 久坐提醒 (LGSedentaryReminderCmd)
`LGSedentaryReminder`表示久坐提醒,默认关闭,有下面几个属性:
- status 开关
- beginTime 开始时间,格式为"HH:mm",比如"09:30"
- endTime 结束时间,格式为"HH:mm",比如"19:30"
- interval 间隔时间，单位为分钟，表示隔多久检测一次，比如半小时
- weekPeriod 周期，LGWeekPeriod
- validSteps 有效步数,运动量大于有效步数才算运动，否则算坐着，默认50

设置久坐提醒，比如开始时间为早上8点，结束时间是晚上10点半，每隔半小时检测一次，周期是每周一到周三，有效步数为100:
```
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
    [self showAlert:_commands[row] msg: error.description];
}] start];

```

读取久坐提醒:
```
LGSedentaryReminderCmd *cmd = [LGSedentaryReminderCmd commandWithAgent:self.agent];
[[cmd readReminderWithSuccess:^(LGSedentaryReminder *reminder) {
    [self showAlert:_commands[row] msg: reminder.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}] start];
```

# 立即睡眠操作(LGSleepActionCmd)
`LGSleepActionCmd`只有一个属性设置`action`，是`LGSleepAction`类型值，只有两种设置:
- LGSleepActionEnter 从运动状态进入睡眠状态，计步功能暂停
- LGSleepActionQuit 从睡眠状态进入运动状态，计步功能开启

使用方法如下:
```
LGSleepActionCmd *cmd = [[LGSleepActionCmd alloc] initWithPeripheralAgent:self.agent];
cmd.action = LGSleepActionEnter;
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}];

```

# 预设睡眠时间(LGSleepSettingsCmd)
`LGSleepSettings`表示，有三个属性:
- status 开关
- sleepTime 睡觉时间,格式为"HH:mm", 如"22:30"
- wakeupTime 醒来时间

如果status是关闭的，sleepTime和wakeupTime会被忽略，都是"00:00"

设置睡觉时间为晚上10点，醒来时间为早上7点:
```
LGSleepSettings *settings = [LGSleepSettings new];
settings.status = YES;
settings.sleepTime = @"22:00";
settings.wakeupTime = @"07:30";

LGSleepSettingsCmd *cmd = [[LGSleepSettingsCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd setSleepTime:settings success:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

读取睡觉时间:
```
LGSleepSettingsCmd *cmd = [[LGSleepSettingsCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readSleepTimeWithSuccess:^(LGSleepSettings *sleepTime) {
    [self showAlert:_commands[row] msg:sleepTime.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

# 运动目标（LGSportGoalsCmd）
达到目标值时，设备会提醒用户。可以设置三个目标:
- 步数
- 卡路里
- 距离

使用类`LGSportGoals`表示，如果为0，则会关闭这个目标提醒。

比如设置步数目标为10000步，卡路里为200**千卡**，关闭距离目标：
```
LGSportGoals *goals = [LGSportGoals new];
goals.steps = 10000;
goals.calory = 200000;
goals.distance = 0;
LGSportGoalsCmd *cmd = [[LGSportGoalsCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd setGoals:goals success:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}] start];

```

读取运动目标:
```
LGSportGoalsCmd *cmd = [[LGSportGoalsCmd alloc] initWithPeripheralAgent:self.agent];
[[cmd readGoalsWithSuccess:^(LGSportGoals *goals){
    [self showAlert:_commands[row] msg:goals.description];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}] start];
```

# 时间设置(LGTimeSettingCmd)
和手机时间相同，使用方法如下:
```
LGTimeSettingCmd *cmd = [[LGTimeSettingCmd alloc] initWithPeripheralAgent:self.agent];
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}];
```

# 时间格式(LGTimeFormatCmd)
有两种时间格式:24小时制和12小时制，对应`LGTimeFormat`枚举值。

设置时间格式:
```
LGTimeFormatCmd *cmd = [LGTimeFormatCmd commandWithAgent:self.agent];
[[cmd setTimeFormat:LGTimeFormat12 success:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

读取时间格式:
```
LGTimeFormatCmd *cmd = [LGTimeFormatCmd commandWithAgent:self.agent];
[[cmd readTimeFormatWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg: integer ? @"12小时制":@"24小时制"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

`LGTimeFormatCmd`有个类方法`+ (LGTimeFormat)systemTimeFormat`，它可以获取系统当前的时间格式。

# 音量操作(LGVolumeSettingCmd)
YTB003带有通话功能，可以播放音乐，接听电话，可以对喇叭音量进行调节。

`LGVolumeSettingCmd`只有一个枚举属性`action`，`LGVolumeAction`类型:
- LGVolumeUpAction 加大音量
- LGVolumeDownAction 降低音量

比如加大音量，代码如下:
```
LGVolumeSettingCmd *cmd = [LGVolumeSettingCmd commandWithAgent:self.agent];
cmd.action = LGVolumeUpAction;
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}];
```

# 天气设置(LGWeatherSettingCmd)
天气可以设置最高温、最低温、天气代码。天气温度单位是摄氏度。

天气代码用`LGWeatherCode`表示，有以下几种类型：
- LGWeatherCodeSunny         晴天
- LGWeatherCodeCloudy        多云
- LGWeatherCodeEveningCloudy 晚间多云
- LGWeatherCodeLightRain     小雨
- LGWeatherCodeHeavyRain     大雨
- LGWeatherCodeRainToSunny   雨转晴
- LGWeatherCodeSnowDay       雪天
- LGWeatherCodeThunderstorms 雷阵雨
- LGWeatherCodeHeavySnow     大雪

设置不同的代码，设备显示不同的图标。

使用方法如下:
```
///设置晴天，最高温28度，最低温23度
LGWeatherSettingCmd *cmd = [LGWeatherSettingCmd commandWithAgent:self.agent];
[cmd setWeatherCode:LGWeatherCodeSunny lowestTemp:23 highestTemp:28];
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}];
```

`LGWeatherSettingCmd`类还可以设置城市名字，使用方法`- (void)setCityName:(NSString *)name;`
使用方法如下:
```
LGWeatherSettingCmd *cmd = [LGWeatherSettingCmd commandWithAgent:self.agent];
[cmd setCityName:@"香港特别行政区"];
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}];
```
城市名称设置有两个限制:
- 只有在设置了温度的情况下才会显示城市名
- 不能设置天气温度的方法一起使用，也就是同一个对象不能连续调用两个方法，以最后一个调用为准

如下代码，只能设置城市名称:
```
LGWeatherSettingCmd *cmd = [LGWeatherSettingCmd commandWithAgent:self.agent];
[cmd setWeatherCode:LGWeatherCodeSunny lowestTemp:23 highestTemp:28];//不起作用
[cmd setCityName:@"香港特别行政区"];
[cmd startWithSuccess:^{
    [self showAlert:_commands[row] msg: @"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg: error.description];
}];
```
所以如果都要设置的话，请创建单独的`LGWeatherSettingCmd`对象.

# 温度单位(LGTempUnitCmd)
温度单位有两种:摄氏度和华氏度，使用枚举`LGTempUnit`表示:
- LGTempUnitCelsius 摄氏度
- LGTempUnitFahrenheit 华氏度

设备会自动根据设置的温度单位显示不同的温度值。

设置单位：
```
LGTempUnitCmd *cmd = [LGTempUnitCmd commandWithAgent:self.agent];
[[cmd setUnit:LGTempUnitFahrenheit success:^{
    [self showAlert:_commands[row] msg:@"成功"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

读取单位:
```
LGTempUnitCmd *cmd = [LGTempUnitCmd commandWithAgent:self.agent];
[[cmd readUnitWithSuccess:^(NSInteger integer) {
    [self showAlert:_commands[row] msg:integer ? @"华氏度" : @"摄氏度"];
} failure:^(NSError *error) {
    [self showAlert:_commands[row] msg:error.description];
}] start];
```

