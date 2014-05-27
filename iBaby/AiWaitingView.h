//
//  AiWaitingView.h
//  iBaby
//
//  Created by yeahugo on 14-5-25.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AiWaitingView : UIView

@property (nonatomic, strong) UIImageView *waitingImageView;

@property (nonatomic, assign) BOOL isShow;

+(void)showInView:(UIView *)superView;

+(void)showInView:(UIView *)superView point:(CGPoint)point;

+ (void)dismiss;
@end
