# mpalertview
[![Version](https://img.shields.io/cocoapods/v/mpalertview.svg?style=flat)](http://cocoapods.org/pods/mpalertview)
[![License](https://img.shields.io/cocoapods/l/mpalertview.svg?style=flat)](http://cocoapods.org/pods/mpalertview)
[![Platform](https://img.shields.io/cocoapods/p/mpalertview.svg?style=flat)](http://cocoapods.org/pods/mpalertview)

一个可自定义view和button数量的alertview，参考自一个开源项目，找不到了，等找到再补上

## 示例
 暂无
 
## 环境

- XCode 9.1+
- iOS 9.1+

## 安装
mpalertview 可以通过 [CocoaPods](http://cocoapods.org) 进行获取。只需要在你的 Podfile 中添加如下代码就能实现引入：

``` ruby
pod "mpalertview"
```

然后，执行如下命令即可：

``` bash
$ pod install
```
## 代码示例

### 简单使用
``` objective-c
#import <mpalertview/mpalertview.h>
...

mpalertview *aview = [[mpalertview alloc]init];
//定义按钮组，可以多个，最好不要超过3个，否则布局不好看
aview.buttonTitles = @[@{@"title":@"取消",@"titleColor":[UIColor whiteColor],@"bgColor":[UIColor greenColor]}
                      ,@{@"title":@"确定",@"titleColor":[UIColor whiteColor],@"bgColor":[UIColor greenColor]}];
aview.bodyMessage = @"是否删除？";
[aview setOnButtonTouchUpInside:^(mpalertview *alertView, int buttonIndex) {
    if (buttonIndex == 0) {
        NSLog(@"点击了第一个按钮");
    }else{
        NSLog(@"点击了第二个按钮");
    }
    [alertView close];
}];
[aview show];
...
```
### 添加自定义view
``` objective-c
#import <mpalertview/mpalertview.h>
...

UIView *cusview = [UIView new];
...
mpalertview *aview = [[mpalertview alloc]init];
//定义按钮组，可以多个，最好不要超过3个，否则布局不好看
aview.buttonTitles = @[@{@"title":@"取消",@"titleColor":[UIColor whiteColor],@"bgColor":[UIColor greenColor]}
                     ,@{@"title":@"确定",@"titleColor":[UIColor whiteColor],@"bgColor":[UIColor greenColor]}];
aview.containerView = cusview; //把自定义的view，set进去
[aview setOnButtonTouchUpInside:^(mpalertview *alertView, int buttonIndex) {
    if (buttonIndex == 0) {
        NSLog(@"点击了第一个按钮");
    }else{
        NSLog(@"点击了第二个按钮");
    }
    [alertView close];
}];
[aview show];
...
```