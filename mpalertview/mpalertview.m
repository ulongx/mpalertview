//
//  mpalertview.m
//  mpalertview
//
//  Created by ulongx on 2017/8/15.
//  Copyright © 2017年 ulongx. All rights reserved.
//

#import "mpalertview.h"

#define MPRGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@implementation mpalertview


CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;
CGFloat buttonSpacerWidth  = 0;

-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _delegate = self;
        _useMotionEffects   = NO;
        _buttonTitles       = @[@{@"title":@"关闭",@"titleColor":MPRGBCOLOR(0,175.5,255),@"bgColor":@"default"}];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
- (void)setSubView: (UIView *)subView{
    _containerView = subView;
}
- (UIView *)createContainerView{
    //如果外部没有创建内容
    if (!_containerView) {
        _containerView = [self defaultContainerView];
    }
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    
    CGFloat cornerRadius = _kAlertViewCornerRadius ? : 7;
    
    [dialogContainer setBackgroundColor: _kBackgroundColor ? : [UIColor whiteColor]];
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderWidth  = 0;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity= 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor  = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath   = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    //按钮上面的分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    lineView.backgroundColor = _kLineViewColor ? : MPRGBCOLOR(198, 198, 198);
    [dialogContainer addSubview:lineView];
    
    //添加外部自定义的内容
    [dialogContainer addSubview:_containerView];
    
    //添加底部button
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}
/**
 *  默认弹出现实内容
 *
 */
- (UIView *)defaultContainerView{
    UIView *k_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, _kContainViewHeight ? : 150)];
    NSString *titleString = _title ? : @"提示";
    
    CGSize titleSize =  [titleString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]} context:nil].size;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(k_containerView.bounds.size.width/2 - titleSize.width/2, 18, titleSize.width, titleSize.height)];
    titleLable.textColor= MPRGBCOLOR(0, 213, 106);
    titleLable.text     = titleString;
    titleLable.font     = [UIFont systemFontOfSize:20];
    [k_containerView addSubview:titleLable];
    
    titleString = _bodyMessage? : @"提示文本内容区域，你可以自定义它";
    titleSize =  [titleString boundingRectWithSize:CGSizeMake(214, MAXFLOAT)
                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil].size;
    
    UILabel *bodyLable = [[UILabel alloc] initWithFrame:CGRectMake(k_containerView.bounds.size.width/2 - titleSize.width/2, 59, titleSize.width, titleSize.height)];
    bodyLable.text     = titleString;
    bodyLable.textColor= MPRGBCOLOR(51, 51, 51);
    bodyLable.textAlignment = NSTextAlignmentCenter;
    bodyLable.numberOfLines = 0;
    bodyLable.font          = [UIFont systemFontOfSize:15];
    [k_containerView addSubview:bodyLable];
    
    return k_containerView;
}

- (void)addButtonsToView: (UIView *)container{
    if (!_buttonTitles) { return; }
    //
    
    CGFloat buttonWidth = container.bounds.size.width / [_buttonTitles count] - (_buttonTitles.count-1)*buttonSpacerWidth/_buttonTitles.count;
    __weak __typeof(&*self)weakSelf = self;
    [_buttonTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bottomButton setFrame:CGRectMake(idx * buttonWidth+(idx*buttonSpacerWidth), container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)];
        
        [bottomButton addTarget:self action:@selector(dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [bottomButton setTag:idx];
        
        NSDictionary *dict = (NSDictionary*)obj;
        
        [bottomButton setTitle:[dict objectForKey:@"title"] forState:UIControlStateNormal];
        [bottomButton setTitleColor:(UIColor*)[dict objectForKey:@"titleColor"] forState:UIControlStateNormal];
        [bottomButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [bottomButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        if ([[dict objectForKey:@"bgColor"] isKindOfClass:[UIColor class]]) {
            [bottomButton setBackgroundColor:(UIColor*)[dict objectForKey:@"bgColor"]];
        }
        if (idx == 0) {
            [weakSelf setMaskLayer:UIRectCornerBottomLeft view:bottomButton];
        }
        if (idx == _buttonTitles.count-1) {
            [weakSelf setMaskLayer:UIRectCornerBottomRight view:bottomButton];
        }
        if (_buttonTitles.count == 1) {
            [weakSelf setMaskLayer:UIRectCornerBottomLeft | UIRectCornerBottomRight view:bottomButton];
        }
        [container addSubview:bottomButton];
        if (_buttonTitles.count > 1 && idx < _buttonTitles.count-1) {
            UIView *vLineView = [[UIView alloc] initWithFrame:CGRectMake((idx+1) * buttonWidth+(idx*buttonSpacerWidth), container.bounds.size.height - buttonHeight, buttonSpacerWidth, buttonHeight)];
            vLineView.backgroundColor = _kLineViewColor ? : MPRGBCOLOR(198, 198, 198);
            [container addSubview:vLineView];
        }
        
    }];
}

-(void)show{
    _dialogView = [self createContainerView];
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:_dialogView];
    
    
    if (_parentView != NULL) {
        [_parentView addSubview:self];
    } else {
        
        CGSize screenSize = [self countScreenSize];
        CGSize dialogSize = [self countDialogSize];
        CGSize keyboardSize = CGSizeMake(0, 0);
        
        _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
        
        [[UIApplication sharedApplication].delegate.window addSubview:self];
    }
    
    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
}

-(void)close{
    CATransform3D currentTransform = _dialogView.layer.transform;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[_dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
        
        _dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }
    
    _dialogView.layer.opacity = 1.0f;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [weakSelf subviews]) {
                             [v removeFromSuperview];
                         }
                         [weakSelf removeFromSuperview];
                     }
     ];
}

- (IBAction)dialogButtonTouchUpInside:(UIButton *)sender{
    if (_delegate != NULL) {
        [_delegate dialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }
    
    if (_onButtonTouchUpInside != NULL) {
        _onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

- (void)dialogButtonTouchUpInside: (mpalertview *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    NSLog(@"点击了按钮 %d, %d", (int)buttonIndex, (int)[alertView tag]);
//    [self close];
}

#pragma mark - button layer 指定圆角

-(void)setMaskLayer:(UIRectCorner)rc view:(UIView*)view{
    CGFloat cornerRadeas = _kAlertViewCornerRadius ? _kAlertViewCornerRadius -1 : 6;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:rc
                                                         cornerRadii:CGSizeMake(cornerRadeas,cornerRadeas)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

#pragma mark - 键盘弹出计算
/**
 *  计数和返回对话框的大小
 */
- (CGSize)countDialogSize{
    CGFloat dialogWidth  = _containerView.frame.size.width;
    CGFloat dialogHeight = _containerView.frame.size.height + buttonHeight + buttonSpacerHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

/**
 *  计数和返回屏幕的大小
 */
- (CGSize)countScreenSize{
    if (_buttonTitles!=NULL && [_buttonTitles count] > 0) {
        buttonHeight       = 50;
        buttonSpacerHeight = 1;
        buttonSpacerWidth  = .5;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
        buttonSpacerWidth  = 0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //在iOS7中，屏幕的宽度和高度不能自动跟踪定位
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

- (void)keyboardWillShow: (NSNotification *)notification{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}

- (void)keyboardWillHide: (NSNotification *)notification{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}

- (void)dealloc{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


@end
