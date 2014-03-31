//
//  AiSearchViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiSearchViewController.h"
#import "AiDataRequestManager.h"

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

-(IBAction)onClickSearchField
{
    NSMutableArray * saveArray = [NSMutableArray array];
    [self.resultGridView removeFromSuperview];
    AiGridView *resultGridView_ = [[AiGridView alloc] initWithFrame:self.backGroundView.frame];
    resultGridView_.backgroundColor = [UIColor clearColor];
    self.resultGridView = resultGridView_;
    [self.view addSubview:self.resultGridView];
    [self.activityView startAnimating];
    [[AiDataRequestManager shareInstance] requestSearchWithKeyWords:self.textField.text startId:[NSNumber numberWithInt:0] completion:^(NSArray *resultArray ,NSError *error){
        [self saveVideoObjects:resultArray saveArray:saveArray error:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
            [self.resultGridView setVideoObjects:saveArray];
            [self.textField resignFirstResponder];
        });
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSMutableArray * saveArray = [NSMutableArray array];
    [self.resultGridView removeFromSuperview];
    AiGridView *resultGridView_ = [[AiGridView alloc] initWithFrame:self.backGroundView.frame];
    self.resultGridView = resultGridView_;
    [self.view addSubview:self.resultGridView];
    [self.activityView startAnimating];
    [[AiDataRequestManager shareInstance] requestSearchWithKeyWords:searchBar.text startId:[NSNumber numberWithInt:0] completion:^(NSArray *resultArray ,NSError *error){
        [self saveVideoObjects:resultArray saveArray:saveArray error:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
            [self.resultGridView setVideoObjects:saveArray];
            [searchBar resignFirstResponder];
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
