//
//  AiSearchViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiSearchViewController.h"
#import "AiDataRequestManager.h"
#import "AiFirstViewController.h"
#import "AiDefaultSearchView.h"
#import "AiWaitingView.h"
#import "AiAudioManager.h"

@interface AiSearchViewController ()

@end

@implementation AiSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.searchViewController = self;
    [self.textField addTarget:self
                  action:@selector(editingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *keysDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/keys.plist",keysDirectory];
    
    NSArray *suggestionArray = [NSArray arrayWithContentsOfFile:filePath];

    [self.textField setSuggestions:suggestionArray];

    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiDefaultSearchView" owner:self options:nil];
    AiDefaultSearchView *defaultSearchView = [nib objectAtIndex:0];
//    NSArray *subViews = [defaultSearchView subviews];
    [[AiDataRequestManager shareInstance] requestSearchRecommend:^(NSArray *resultArray, NSError *error) {
//        NSLog(@"requestSearchRecommend resultArray is %@",resultArray);
        for (int i= 0; i<resultArray.count; i++) {
            ResourceInfo *resourceInfo = [resultArray objectAtIndex:i];
            AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
            UIView *subView = [defaultSearchView viewWithTag:100+i];
//            NSLog(@"subView frame is %@",NSStringFromCGRect(subView.frame));
            AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:subView.frame cellType:kViewCellTypeSearchRecommend];
            scrollViewCell.aiVideoObject = videoObject;
            [scrollViewCell.imageButton setImage:nil forState:UIControlStateNormal];
            [self.backGroundView addSubview:scrollViewCell];
        }
    }];

    // Do any additional setup after loading the view.
}

-(void)saveVideoObjects:(NSArray *)resultArray saveArray:(NSMutableArray *)saveArray error:(NSError *)error
{
    if (error == nil) {
        for (int i = 0; i < resultArray.count; i++) {
            AiVideoObject *videoObject = [[AiVideoObject alloc] init];
            ResourceInfo *resourceInfo = [resultArray objectAtIndex:i];
            videoObject.title = resourceInfo.title;
            videoObject.imageUrl = resourceInfo.img;
            videoObject.vid = resourceInfo.url;
            videoObject.sourceType = resourceInfo.resourceType;
            [saveArray addObject:videoObject];
        }
    } else{
        NSLog(@"error is %@",error);
    }
}

-(IBAction)close:(id)sender
{
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
    AiFirstViewController  *rootViewController = (AiFirstViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController resetButtons];
}

-(void)removeAllSubView
{
    for (UIView *subView in self.backGroundView.subviews) {
        [subView removeFromSuperview];
    }
}

-(IBAction)onClickSearchWords:(NSString *)keyWords
{
    [self.textField.popOver dismissPopoverAnimated:YES];
    [self removeAllSubView];
    NSString *keywords = nil;
    if (keyWords == nil) {
        keywords = @"";
    } else {
        keywords = keyWords;
    }
    [self.textField resignFirstResponder];
    
    UIView *scrollView = [self.view viewWithTag:2000];
    if (scrollView) {
        [scrollView removeFromSuperview];
    }
    UIView *albumView = [self.view viewWithTag:2001];
    if (albumView) {
        [albumView removeFromSuperview];
    }
    
    AiScrollViewController *scrollViewController = [[AiScrollViewController alloc] initWithFrame:self.backGroundView.frame keyWords:keywords];
    self.scrollViewController = scrollViewController;
    self.scrollViewController.scrollView.tag = 2000;
    [self.view addSubview:self.scrollViewController.scrollView];

    [AiWaitingView showInView:self.view point:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
}

-(IBAction)onClickSearchField
{
    [self onClickSearchWords:self.textField.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editingChanged:(UITextField *)textField
{
    [self.textField matchStrings:textField.text];
    [self.textField showPopOverList];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onClickSearchField];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[self.textField popOver] dismissPopoverAnimated:YES];
    return YES;
}

@end
