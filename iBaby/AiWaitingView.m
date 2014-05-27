//
//  AiWaitingView.m
//  iBaby
//
//  Created by yeahugo on 14-5-25.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiWaitingView.h"

@implementation AiWaitingView

+ (AiWaitingView *)shareInstance {
    static AiWaitingView *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        }
    }
    return _instance;
}

+ (void)showInView:(UIView *)superView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([self shareInstance].isShow == YES) {
//            NSLog(@"showInView !!!!!!");
            [self shareInstance].waitingImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.height/2, [[UIScreen mainScreen] bounds].size.width/2);
//            NSLog(@"waitingImage is %@",[self shareInstance].waitingImageView);
            [superView addSubview:[self shareInstance].waitingImageView];
            [[self shareInstance].waitingImageView startAnimating];
        }
    });
}

+(void)showInView:(UIView *)superView point:(CGPoint)point
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
    [[self shareInstance].waitingImageView removeFromSuperview];
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
