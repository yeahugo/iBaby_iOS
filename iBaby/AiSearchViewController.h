//
//  AiSearchViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiGridView.h"

@interface AiSearchViewController : UIViewController<UISearchBarDelegate>

@property (nonatomic, assign) IBOutlet UIView * backGroundView;

@property (nonatomic, assign) AiGridView *resultGridView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, assign) IBOutlet UITextField *textField;

-(IBAction)onClickSearchField;
@end
