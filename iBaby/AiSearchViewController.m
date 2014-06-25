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
#import "AiScrollViewCell.h"

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
    [[AiDataRequestManager shareInstance] requestSearchRecommend:^(NSArray *resultArray, NSError *error) {
        for (int i= 0; i<resultArray.count; i++) {
            ResourceInfo *resourceInfo = [resultArray objectAtIndex:i];
            UIView *subView = [defaultSearchView viewWithTag:100+i];
            AiScrollViewCell *scrollViewCell = [[AiScrollViewCell alloc] initWithFrame:subView.frame cellType:kViewCellTypeSearchRecommend];
            scrollViewCell.resourceInfo = resourceInfo;
            [scrollViewCell reloadResourceInfo];
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
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
    AiFirstViewController  *rootViewController = (AiFirstViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController resetButtons];
}

-(void)removeAllSubView
{
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
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
    [self clickKeyWords:keyWords resourceType:kSearchViewTypeAll];

    [AiWaitingView showInView:self.view point:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
}

-(void)clickKeyWords:(NSString *)keyWords resourceType:(int)resourceType
{
//    [_songListArray removeAllObjects];
    if (keyWords) {
        self.keyWords = keyWords;
    }
    _startId = 0;
    self.searchViewType = resourceType;
    if (self.scrollView == nil) {
        AiScrollView *scrollView = [[AiScrollView alloc] initWithFrame:self.backGroundView.frame];
        scrollView.scrollViewDelegate = self;
        scrollView.viewType = kTagViewTypeSearch;
        self.scrollView = scrollView;
        [self.view addSubview:self.scrollView];
    }
    [self removeAllSubViews];
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestSearchWithKeyWords:self.keyWords startId:[NSNumber numberWithInt:_startId] resourceType:resourceType completion:^(NSArray *resultArray,NSError *error){
        [AiWaitingView dismiss];
        if (error == nil) {
            if (resultArray.count == 0) {
                UIImageView *noResultImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_results"]];
                noResultImage.center = CGPointMake(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
                noResultImage.tag = 5;
                [self.scrollView addSubview:noResultImage];
                return;
            } else {
                _startId = _startId + resultArray.count;
                ResourceInfo *firstResourceInfo = [resultArray objectAtIndex:0];
                self.firstVideoObject = [[AiVideoObject alloc] initWithResourceInfo:firstResourceInfo];
//                [_songListArray addObjectsFromArray:saveSongArray];
                [self.scrollView setAiVideoObjects:resultArray];
            }
        }
    }];
}

#pragma mark AiScrollViewDelegate
-(int)scrollViewReload
{
    AiVideoObject *firstVideoObject = self.firstVideoObject;
    int returnOffSet = 0;
//    if (self.songListArray.count > 0) {
//        firstVideoObject = [self.songListArray objectAtIndex:0];
//    }
    //搜索页面推荐效果
    if (firstVideoObject.status == 1) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AiSearchRecommendView" owner:self options:nil];
        
        AiSearchRecommendView *searchRecommendView = [nib objectAtIndex:0];
        searchRecommendView.videoObject = [firstVideoObject copy];
        searchRecommendView.keyWords = self.keyWords;
        //专辑标题
        if ([self.keyWords isEqualToString:firstVideoObject.serialTitle]) {
            [searchRecommendView.albumTitle setText:firstVideoObject.serialTitle];
        } else{
            [searchRecommendView.albumTitle setText:firstVideoObject.title];
        }
        [searchRecommendView.introText setText:firstVideoObject.serialDes];
        searchRecommendView.tag = 2001;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:firstVideoObject.imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [searchRecommendView.albumImage setImage:image];
        [self.scrollView addSubview:searchRecommendView];
        
//        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"break line"]];
//        line.center = CGPointMake(self.frame.size.width/2, searchRecommendView.frame.size.height);
//        [self.view addSubview:line];
//        
        returnOffSet = searchRecommendView.frame.size.height + 40;
        
        [self addButtonsFromOffSet:searchRecommendView.frame.size.height];
    }
    else {
        returnOffSet = 150;
        [self addButtonsFromOffSet:returnOffSet - 45];
    }
    return returnOffSet;
}

-(void)getMoreData:(int)totalNum
{
    [[AiDataRequestManager shareInstance] requestSearchWithKeyWords:self.keyWords startId:[NSNumber numberWithInt:_startId] resourceType:self.searchViewType completion:^(NSArray *resultArray,NSError *error){
        if (error == nil) {
            _startId = _startId + resultArray.count;
            [self.scrollView addAiVideoObjects:resultArray];
        }
    }];
}

-(void)addButtonsFromOffSet:(float)offset
{
    CGSize size = CGSizeMake(55, 31);
    int deltaX = 10+size.width;
    UIButton * allButton = [[UIButton alloc] initWithFrame:CGRectMake(0, offset, size.width, size.height)];
    self.allButton = allButton;
    [self.allButton addTarget:self action:@selector(searchAll:) forControlEvents:UIControlEventTouchUpInside];
    [allButton setTitle:@"全部" forState:UIControlStateNormal];
    [self.scrollView addSubview:self.allButton];
    
    UIButton *songButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX, offset, size.width, size.height)];
    self.songButton = songButton;
    [self.songButton addTarget:self action:@selector(searchSong:) forControlEvents:UIControlEventTouchUpInside];
    [songButton setTitle:@"儿歌" forState:UIControlStateNormal];
    
    [self.scrollView addSubview:self.songButton];
    
    UIButton *catoonButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX * 2, offset, size.width, size.height)];
    self.cattonButton = catoonButton;
    [self.cattonButton addTarget:self action:@selector(searchCatoon:) forControlEvents:UIControlEventTouchUpInside];
    [catoonButton setTitle:@"动画" forState:UIControlStateNormal];
    
    [self.scrollView addSubview:self.cattonButton];
    
    UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake(deltaX * 3, offset, size.width, size.height)];
    self.videoButton = videoButton;
    [self.videoButton addTarget:self action:@selector(searchVideo:) forControlEvents:UIControlEventTouchUpInside];
    [videoButton setTitle:@"节目" forState:UIControlStateNormal];
    
    [self.scrollView addSubview:self.videoButton];
    
    self.chooseView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose"]];
    if (self.searchViewType == kSearchViewTypeAll) {
        [self.allButton addSubview:self.chooseView];
    }
    if (self.searchViewType == kSearchViewTypeSong) {
        [self.songButton addSubview:self.chooseView];
    }
    if (self.searchViewType == kSearchViewTypeCatoon) {
        [self.cattonButton addSubview:self.chooseView];
    }
    if (self.searchViewType == kSearchViewTypeVideo) {
        [self.videoButton addSubview:self.chooseView];
    }
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

-(void)removeAllSubViews
{
    NSArray * views = [self.scrollView subviews];
    for (UIView * view in views) {
        [view removeFromSuperview];
    }
}

-(void)searchAll:(UIButton *)button
{
    [self removeAllSubViews];
    [AiWaitingView showInView:self.view point:CGPointMake(100, 100)];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeAll;
    [self clickKeyWords:nil resourceType:-1];
}

-(void)searchSong:(UIButton *)button
{
    [self removeAllSubViews];
    [AiWaitingView showInView:self.view point:CGPointMake(100, 100)];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeSong;
    [self clickKeyWords:nil resourceType:kSearchViewTypeSong];
}

-(void)searchCatoon:(UIButton *)button
{
    [self removeAllSubViews];
    [AiWaitingView showInView:self.view point:CGPointMake(100, 100)];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeCatoon;
    [self clickKeyWords:nil resourceType:kSearchViewTypeCatoon];
}

-(void)searchVideo:(UIButton *)button
{
    [self removeAllSubViews];
    [AiWaitingView showInView:self.view point:CGPointMake(100, 100)];
    [self.chooseView removeFromSuperview];
    self.searchViewType = kSearchViewTypeVideo;
    [self clickKeyWords:nil resourceType:kSearchViewTypeVideo];
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
