//
//  AiFavouriteViewController.h
//  iBaby
//
//  Created by yeahugo on 14-4-23.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AiGridViewController.h"
#import "AiIndexViewController.h"

@interface AiFavouriteViewController : UIViewController
{
//    AiGridViewController *_favouriteViewController;
    AiIndexViewController *_favouriViewController;
}

@property (nonatomic, assign) IBOutlet UIView * backGroundView;

-(IBAction)close:(id)sender;

@end
