# LGBluetooth


## 概要
LGBluetooth是iOS的动态框架，使用Objective-C语言开发，封装了[深圳云图科技公司](http://cloudtootech.com)智能穿戴产品的蓝牙协议。
## 系统要求
- iOS 8.0 + 
- Xcode 8 +

## 安装
- 前往Xcode 工程的`General`设置项中，将`LGBluetooth.framework`拖曳到`Embedded Binaries`选项中。确认Copy items if needed被选中后，点击Finish按钮；
- import framework
- 如果需要后台使用蓝牙，请将Project——Target——Capabilities——Backgroud Modes打开，勾选里面的**Uses Bluetooth LE accessories**。

## 使用说明

* [基本介绍](docs/basic.md)
* [数据同步](docs/data.md)
* [功能设置](docs/settings.md)
* [软件更新](docs/upgrade.md)
* [地图更新](docs/mapUpdate.md)
* [错误说明](docs/error.md)

## 版本更新
版本| 时间 | 内容
--- | --- | --- 
1.0 | 2016-09-08 | 第一个版本发布
1.0.1 | 2016-09-22 | 1.兼容Xcode 8，iOS 10，DFU升级到Swift 2.3 <br> 2.修改固件升级逻辑 3.增加写序列号功能
1.0.2 | 2016-09-24 | 增加GPS信息解析功能(LGGPSInfoCmd)
1.1 | 2016-10-21 | 增加地图升级功能
