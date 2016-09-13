# LGBluetooth


## 概要
LGBluetooth是iOS的动态框架，使用Objective-C语言开发，封装了[深圳云图科技公司](http://cloudtootech.com)智能穿戴产品的蓝牙协议。
## 系统要求
- iOS 8.0 + 
- Xcode 7.3 +

## 安装
- 前往Xcode 工程的`General`设置项中，将`LGBluetooth.framework`和`DFULibrary.framework`拖曳到`Embedded Binaries`选项中。确认Copy items if needed被选中后，点击Finish按钮；
- import framework
- 如果需要后台使用蓝牙，请将Project——Target——Capabilities——Backgroud Modes打开，勾选里面的**Uses Bluetooth LE accessories**。

## 使用说明

* [基本介绍](docs/basic.md)
* [数据同步](docs/data.md)
* [功能设置](docs/settings.md)
* [软件更新](docs/upgrade.md)
* [错误说明](docs/error.md)
* [版本历史](docs/version.md)