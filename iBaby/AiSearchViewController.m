//
//  AiSearchViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiSearchViewController.h"
#import "AiDataRequestManager.h"
#import "AiGridViewController.h"
#import "AiFirstViewController.h"

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
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake(200, 120);
    [self.view addSubview:_activityView];
    self.textField.delegate = self;

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
    AiFirstViewController  *rootViewController = (AiFirstViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController closeSheetController];
}

-(IBAction)onClickSearchField
{
    NSString *keywords = nil;
    if (self.textField.text == nil) {
        keywords = @"";
    } else {
        keywords = self.textField.text;
    }
    [self.textField resignFirstResponder];
    
    if (self.gridViewController == nil) {
        AiGridViewController *gridViewController = [[AiGridViewController alloc] initWithFrame:self.backGroundView.frame keyWords:keywords];
        self.gridViewController = gridViewController;
        [self.view addSubview:self.gridViewController.swipeView];
    } else {
        [self.gridViewController clickKeyWords:keywords];
        [self.gridViewController.swipeView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    AiFirstViewController *firstViewController = (AiFirstViewController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    if (firstViewController.closeButton) {
        UIButton * closeButton = firstViewController.closeButton;
        closeButton.center = CGPointMake(closeButton.center.x, closeButton.center.y - 50);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AiFirstViewController *firstViewController = (AiFirstViewController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    UIButton * closeButton = firstViewController.closeButton;
    closeButton.center = CGPointMake(closeButton.center.x, closeButton.center.y + 50);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onClickSearchField];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
