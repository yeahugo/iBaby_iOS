//
//  AiWaitingView.m
//  iBaby
//
//  Created by yeahugo on 14-5-25.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiWaitingView.h"
#import "AiAudioManager.h"

@implementation AiWaitingView

+ (AiWaitingView *)shareInstance {
    static AiWaitingView *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            _instance.isShow = YES;
        }
    }
    return _instance;
}

+(void)addNoNetworkTip
{
//    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    NSLog(@"subView is %@",window.subviews);
    if ([window viewWithTag:100]) {
        return;
    }
    UIImage *unreachableImage = [UIImage imageNamed:@"no_network"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:unreachableImage];
    
    UIViewController  *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if (rootViewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        imageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    } else {
        imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    if (rootViewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        imageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    } else {
        imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    imageView.center = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
    imageView.tag = 101;
    //    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    UIButton *unreachButton = [[UIButton alloc] initWithFrame:rootViewController.view.frame];
    [unreachButton setBackgroundColor:[UIColor lightGrayColor]];
    [unreachButton addTarget:[self shareInstance] action:@selector(removeUnreach:) forControlEvents:UIControlEventTouchUpInside];
    unreachButton.tag = 100;
    unreachButton.alpha = 0.6;
    [window addSubview:unreachButton];
    [window addSubview:imageView];
    [AiAudioManager play:@"no_network"];
}

+(void)addNoNetworkTip:(UIView *)superView
{
//    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if ([window viewWithTag:100]) {
        return;
    }
//    UIViewController  *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIImage *unreachableImage = [UIImage imageNamed:@"no_network"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:unreachableImage];
    imageView.center = CGPointMake(superView.frame.size.width/2, superView.frame.size.height/2);
    imageView.tag = 101;
    //    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    UIButton *unreachButton = [[UIButton alloc] initWithFrame:superView.frame];
    [unreachButton setBackgroundColor:[UIColor lightGrayColor]];
    [unreachButton addTarget:[self shareInstance] action:@selector(removeUnreach:) forControlEvents:UIControlEventTouchUpInside];
    unreachButton.tag = 100;
    unreachButton.alpha = 0.6;
    [superView addSubview:unreachButton];
    [superView addSubview:imageView];
    [AiAudioManager play:@"no_network"];
}

-(void)removeUnreach:(UIButton *)button
{
    [button removeFromSuperview];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *subView = [window viewWithTag:101];
    [subView removeFromSuperview];
}

+(void)show
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([AiWaitingView shareInstance].isShow == YES) {
            [self shareInstance].waitingImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.height/2, [[UIScreen mainScreen] bounds].size.width/2);
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:[self shareInstance].waitingImageView];
            [[self shareInstance].waitingImageView startAnimating];
        }
    });
}

+ (void)showInView:(UIView *)superView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([self shareInstance].isShow == YES) {
            [self shareInstance].waitingImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.height/2, [[UIScreen mainScreen] bounds].size.width/2);
            [superView addSubview:[self shareInstance].waitingImageView];
            [[self shareInstance].waitingImageView startAnimating];
        }
    });
}

+(void)showInView:(UIView *)superView point:(CGPoint)point
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([self shareInstance].isShow == YES) {
            [self shareInstance].waitingImageView.center = point;
            [superView addSubview:[self shareInstance].waitingImageView];
            [[self shareInstance].waitingImageView startAnimating];
        }
    });
}

+ (void)dismiss
{
    [self shareInstance].isShow = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC),dispatch_get_main_queue(), ^{
        [self shareInstance].isShow = YES;
        [[self shareInstance].waitingImageView removeFromSuperview];
    });
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isShow = YES;
        UIImageView * waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waiting_1"]];
        NSArray *array = [NSArray arrayWithObjects:[UIImage imageNamed:@"waiting_1"],[UIImage imageNamed:@"waiting_2"], [UIImage imageNamed:@"waiting_3"],[UIImage imageNamed:@"waiting_3"],[UIImage imageNamed:@"waiting_4"],[UIImage imageNamed:@"waiting_4"], [UIImage imageNamed:@"waiting_5"],nil];
        [waitingImageView setAnimationImages:array];
        waitingImageView.animationDuration = 1;
        self.waitingImageView = waitingImageView;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
