//
//  ViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiGridView.h"
#import "SwipeView.h"

@interface AiFirstViewController : UIViewController <SwipeViewDataSource>

@property (nonatomic, assign) IBOutlet UIButton *songButton;

@property (nonatomic, assign) IBOutlet UIButton *catoonButton;

@property (nonatomic, assign) IBOutlet UIButton *videoButton;

@property (nonatomic, assign) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) AiGridView *songGridView;

@property (nonatomic, strong) AiGridView *catoonGridView;

@property (nonatomic, strong) AiGridView *videoGridView;

@property (nonatomic, strong) SwipeView *swipeview;

-(IBAction)onClickButton:(id)sender;

-(IBAction)onClickSearch:(id)sender;

-(IBAction)onClickHistory:(id)sender;

@end
