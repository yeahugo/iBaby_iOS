//
//  AiWebViewPlayerController.h
//  iBaby
//
//  Created by yeahugo on 14-6-7.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiPlayerViewController.h"

@interface AiWebViewPlayerController : AiPlayerViewController
<UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (nonatomic, assign) UIButton *webViewButton;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UITapGestureRecognizer *recognizer;

-(void)addWebViewButton;
@end
