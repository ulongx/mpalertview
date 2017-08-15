//
//  mpalertview.h
//  mpalertview
//
//  Created by ulongx on 2017/8/15.
//  Copyright © 2017年 ulongx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPAlertViewDelegate

- (void)dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
@interface mpalertview : UIView<MPAlertViewDelegate>

@property (nonatomic, strong) id<MPAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray                 *buttonTitles;
@property (nonatomic, assign) BOOL                    useMotionEffects;

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIView *dialogView;
@property (nonatomic, retain) UIView *containerView;

//定义外框的圆角弧度
@property (nonatomic, assign) CGFloat kAlertViewCornerRadius;
@property (nonatomic, strong) UIColor *kBackgroundColor;
@property (nonatomic, strong) UIColor *kLineViewColor;

@property (nonatomic, assign) NSUInteger    kContainViewHeight;

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *bodyMessage;

@property (nonatomic, copy) void (^onButtonTouchUpInside)(mpalertview *alertView, int buttonIndex);

- (instancetype)init;

- (void)show;
- (void)close;

- (void)setOnButtonTouchUpInside:(void (^)(mpalertview *alertView, int buttonIndex))onButtonTouchUpInside;

@end
