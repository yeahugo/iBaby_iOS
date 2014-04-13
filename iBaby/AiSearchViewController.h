//
//  AiSearchViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiGridViewController.h"

@interface AiSearchViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UIView * backGroundView;

@property (nonatomic, strong) AiGridViewController *gridViewController;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, assign) IBOutlet UITextField *textField;

-(IBAction)onClickSearchField;

@end
