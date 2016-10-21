# 地图更新(LGMapDataManager)

## 说明

蓝牙传输速率大约2KB/s。

由于地图文件比较大，升级过程要很久，假如15MB的地图文件，整个过程耗时约2小时。所以尽量不要移动手机和手环，保持各自的电量充足。

在LGBluetoothExample里面，已经有一个例子，其中的核心就是`LGMapDataManager`类。

## 使用方法

1. 实现协议`LGMapDataManagerDelegate`方法

```objective-c
/**
 进入升级模式, 最先回调。
 */
- (void)enterUpdatingMode;

/**
 完成更新
 */
- (void)updatingSuccessful;

/**
 更新进度

 @param progress 进度
 */
- (void)updatingProgress:(float)progress;

/**
 中断更新

 @param error 发生错误
 */
- (void)interupteWithErrorType:(LGMapErrorType)errorType message:(NSString *)message;
```

2. 初始化`LGMapDataManager`，参数传入地图文件路径和升级设备

```objective-c
self.manager = [[LGMapDataManager alloc] initWithFileUrl:filePath peripheral:self.peripheral];
self.manager.delegate = self;
```

3. 调用 `- (void)startUpdating`开始更新

## 错误类型
 - LGMapErrorTypeNoError:       成功
 - LGMapErrorTypeConnectFailed: 设备未连接、连接不成功超时
 - LGMapErrorTypeWrongURL:      map文件URL错误
 - LGMapErrorTypeFailed:        升级失败
 - LGMapErrorTypeLengthWrong:   升级长度错误
 - LGMapErrorTypeCommandWrong:  升级命令错误
 - LGMapErrorTypeCRCWrong:      升级包CRC校验错误
 - LGMapErrorTypeUnknown:       未知错误

## 测试方法
`- (void)stopUpdatingForTest` 手动断开传输过程。

**此方法仅用于测试情况，正常情况下不需要调用这个函数**