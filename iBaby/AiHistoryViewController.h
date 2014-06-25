//
//  AiHistoryViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AiGridViewController.h"
#import "AiIndexViewController.h"
#import "AiScrollView.h"

@interface AiHistoryViewController : UIViewController
{
//    AiIndexViewController *_scrollViewController;
//    AiGridViewController *_historyViewController;
}

@property (nonatomic, assign) IBOutlet AiScrollView *scrollView;

-(IBAction)close:(id)sender;

@end
