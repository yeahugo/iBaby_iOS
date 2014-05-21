//
//  AiSearchViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AiGridViewController.h"
#import "AiScrollViewController.h"
#import "SuggestiveTextField.h"

@interface AiSearchViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UIView * backGroundView;

@property (nonatomic, strong) AiScrollViewController *scrollViewController;

@property (nonatomic, strong) IBOutlet SuggestiveTextField *textField;

@property (nonatomic, assign) id firstViewController;

-(IBAction)onClickSearchField;

-(IBAction)onClickSearchWords:(NSString *)keyWords;

-(IBAction)close:(id)sender;
@end
