# 错误说明
所有的错误使用NSError返回，NSError的code是LGErrorType类型，定义在"NSError+Peripheral.h"里面，具体如下:
```
typedef NS_ENUM(NSInteger, LGErrorType) {
    /**
     *  蓝牙未打开
     */
    LGErrorTypeCentralNotOpened                  = 0,
    /**
     *  设备未连接
     */
    LGErrorTypePeripheralNotConnected            = 1,
    /**
     *  设备连接失败
     */
    LGErrorTypePeripheralConnectTimeout          = 2,
    /**
     *  设备服务未找到
     */
    LGErrorTypePeripheralServiceNotFound         = 3,
    /**
     *  设备特征未找到
     */
    LGErrorTypePeripheralCharacteristicsNotFound = 4,
    /**
     *  设备响应超时
     */
    LGErrorTypePeripheralResponseTimeout         = 5,
    /**
     *  命令格式错误
     */
    LGErrorTypeCommandFormatWrong                = 6,
    /**
     *  命令CRC校验错误
     */
    LGErrorTypeResonseCommandCRCWrong            = 7,
    /**
     *  响应失败
     */
    LGErrorTypeResonseFailed                     = 8,
    /**
     *  批量数据数量有错（步数、睡眠、心率）
     */
    LGErrorTypeResponseDataCountWrong            = 9,
    /**
     *  命令没有发送对象Peripheral
     */
    LGErrorTypeCommandWithoutPeripheral          = 10,
    /**
     *  命令没有SendingData
     */
    LGErrorTypeCommandWithoutSendingData         = 11,
};

```