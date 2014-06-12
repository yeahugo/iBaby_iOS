//
//  AiWebViewPlayerController.h
//  iBaby
//
//  Created by yeahugo on 14-6-7.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiPlayerViewController.h"

@interface AiWebViewPlayerController : UIViewController
<UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (nonatomic, assign) UIButton *webViewButton;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) AiPlayerViewControl *playControlView;

@property (nonatomic, strong) NSArray * videoArray;

@property (nonatomic, assign) BOOL isLike;

@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, assign) BOOL isOnVolumn;

@property (nonatomic, assign) float volume;

@property (nonatomic, strong) NSTimer * timer;

@property (nonatomic, strong) UITapGestureRecognizer *recognizer;

-(id)initWithVid:(NSString *)vid;

-(void)addWebViewButton;
@end
