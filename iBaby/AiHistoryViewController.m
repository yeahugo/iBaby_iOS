//
//  AiHistoryViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-29.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiHistoryViewController.h"
#import "AiDataBaseManager.h"
#import "AiGridView.h"
#import "AiGridViewController.h"

@interface AiHistoryViewController ()

@end

@implementation AiHistoryViewController

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
    
    _historyViewController = [[AiGridViewController alloc] initWithFrame:self.backGroundView.frame keyWords:nil];
    _historyViewController.sourceType = kDataSourceTypeDatabase;
    [self.view addSubview:_historyViewController.swipeView];
      
    [[AiDataBaseManager shareInstance] getVideoListsWithCompletion:^(NSArray *videoList, NSError *error) {
        if (error == nil) {
            NSArray *videos = [self makeVideoArrays:videoList];
            [_historyViewController.songListArray addObjectsFromArray:videos];
            [_historyViewController.swipeView reloadData];
        } else {
            NSLog(@"getVideoList error is %@",error);
        }
    }];
    // Do any additional setup after loading the view.
}

-(NSMutableArray *)makeVideoArrays:(NSArray *)videoList
{
    NSMutableArray *resultArray = [NSMutableArray array];
    int resultCount = videoList.count/ShowNum + 1;
    for (int i = 0; i < resultCount; i++) {
        NSRange range = {0,0};
        if (i == resultCount - 1) {
            NSRange range1 = {i*ShowNum,videoList.count - i*ShowNum};
            range = range1;
        } else {
            NSRange range1 = {i*ShowNum, ShowNum};
            range = range1;
        }
        NSArray * videos = [videoList subarrayWithRange:range];
        [resultArray addObject:videos];
    }
    return resultArray;
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
