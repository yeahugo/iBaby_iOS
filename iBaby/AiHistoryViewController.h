//
//  AiHistoryViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AiGridViewController.h"
#import "AiScrollViewController.h"

@interface AiHistoryViewController : UIViewController
{
    AiScrollViewController *_scrollViewController;
//    AiGridViewController *_historyViewController;
}

@property (nonatomic, assign) IBOutlet UIView *backGroundView;

-(IBAction)close:(id)sender;

@end
