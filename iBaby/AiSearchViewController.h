//
//  AiSearchViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiScrollView.h"
//#import "AiGridViewController.h"
//#import "AiScrollViewController.h"
#import "SuggestiveTextField.h"

@interface AiSearchViewController : UIViewController
<UITextFieldDelegate,AiScrollViewDelegate,EGORefreshTableHeaderDelegate>

@property (nonatomic, assign) IBOutlet UIView * backGroundView;

@property (nonatomic, copy) NSString *keyWords;

@property (nonatomic, assign) kSearchViewType searchViewType;

@property (nonatomic, strong) AiVideoObject *firstVideoObject;

//@property (nonatomic, strong) NSMutableArray *songListArray;

@property (nonatomic, strong) IBOutlet SuggestiveTextField *textField;

@property (nonatomic, assign) id firstViewController;

@property (nonatomic, assign) int startId;

@property (nonatomic, strong) AiScrollView *scrollView;

@property (nonatomic, strong) UIButton *songButton;

@property (nonatomic, strong) UIButton *allButton;

@property (nonatomic, strong) UIButton *cattonButton;

@property (nonatomic, strong) UIButton *videoButton;

@property (nonatomic, strong) UIImageView *chooseView;

//@property (nonatomic, strong) AiScrollViewController *scrollViewController;

-(IBAction)onClickSearchField;

-(IBAction)onClickSearchWords:(NSString *)keyWords;

-(IBAction)close:(id)sender;
@end
