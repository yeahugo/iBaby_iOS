//
//  ViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiGridView.h"

@interface AiFirstViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIButton *songButton;

@property (nonatomic, assign) IBOutlet UIButton *catoonButton;

@property (nonatomic, assign) IBOutlet UIButton *videoButton;

@property (nonatomic, assign) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) AiGridView *songGridView;

@property (nonatomic, strong) AiGridView *catoonGridView;

@property (nonatomic, strong) AiGridView *videoGridView;

-(IBAction)onClickButton:(id)sender;

@end
