//
//  AiScrollViewController.m
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiIndexViewController.h"
#import "AiDataRequestManager.h"
#import "AiDataBaseManager.h"
#import "AiBannerView.h"
#import "AiWaitingView.h"

@implementation AiIndexViewController
-(id)initWithFrame:(CGRect)frame recommend:(int)resourceType completion:(void (^)(void))completion
{
    if (self) {
        _songListArray = [[NSMutableArray alloc] init];
        self.resourceType = resourceType;
        self.viewType = kTagViewTypeIndex;
        
        _startId = 0;
        AiScrollView *scrollView = [[AiScrollView alloc] initWithFrame:frame];
        scrollView.pageCount = SearchNum;
        self.scrollView = scrollView;
        self.scrollView.viewType = kTagViewTypeIndex;
        self.scrollView.delegate = self;
//        self.scrollView.scrollViewController = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.scrollViewDelegate = self;
        [self getRecommendResource:resourceType completion:completion];
    }
    return self;
}

-(void)getRecommendResource:(int)resourceType completion:(void (^)(void))completion
{
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestRecommendWithType:resourceType startId:_startId totalNum:SearchNum completion:^(NSArray *resultArray,NSError *error){
        [AiWaitingView dismiss];
        if (error == nil) {
            _startId = _startId + (int)resultArray.count;
            [self.songListArray addObjectsFromArray:resultArray];
            [self.scrollView setAiVideoObjects:resultArray];
            
            if (completion) {
                completion();
            }
        } else {
            NSLog(@"error is %@",error);
        }
    }];
}

#pragma mark AiScrollViewDelegate
-(int)scrollViewReload
{
    AiBannerView *bannerView = [[AiBannerView alloc] initWithFrame:CGRectMake( 0, 0, self.scrollView.frame.size.width, 296) videoDatas:self.songListArray scrollView:self.scrollView];
    [self.scrollView addSubview:bannerView];
    int cellOffSetY = 322;
    return cellOffSetY;
}

-(void)getMoreData:(int)totalNum
{
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestRecommendWithType:self.resourceType startId:_startId totalNum:totalNum completion:^(NSArray *resultArray, NSError *error) {
        if (error == nil) {
            _startId = _startId + resultArray.count;
            if (self.leftDatas.count > 0) {
                NSMutableArray * newArray = [NSMutableArray arrayWithArray:self.leftDatas];
                [newArray addObjectsFromArray:resultArray];
                [self.scrollView addAiVideoObjects:newArray];
                self.leftDatas = nil;
            } else {
                [self.scrollView addAiVideoObjects:resultArray];
            }
            if (resultArray.count == SearchNum - _leftNum) {
                EGORefreshTableHeaderView * egoFooterView = self.scrollView.egoFooterView;
                egoFooterView.center = CGPointMake(egoFooterView.center.x, self.scrollView.contentSize.height + egoFooterView.frame.size.height/2);
                _leftNum = 0;
            } else {
                self.scrollView.egoFooterView.hidden = YES;
            }
        }
    }];
}

-(NSArray *)showVideoArray:(NSArray *)videoArray
{
    NSMutableArray * normalDatas = [self getNormalVideoDatas:videoArray];
    if (normalDatas.count %ColNum !=0) {
        _leftNum = normalDatas.count % ColNum;
        NSRange range = NSMakeRange(normalDatas.count-_leftNum, _leftNum);
//        NSArray * leftDatas = [normalDatas subarrayWithRange:range];
        self.leftDatas = [normalDatas subarrayWithRange:range];
        [normalDatas removeObjectsInRange:range];
//        [videoDatas removeObjectsInRange:NSMakeRange(self.videoDatas.count - _leftNum,_leftNum)];
    }
    return normalDatas;
}

-(NSMutableArray *)getNormalVideoDatas:(NSArray *)sourceArray
{
    NSMutableArray *normalVideoObject = [NSMutableArray array];
    for (AiVideoObject * videoObject in sourceArray) {
        if (videoObject.status == RESOURCE_STATUS_NORMAL) {
            [normalVideoObject addObject:videoObject];
        }
    }
    return normalVideoObject;
}


-(BOOL)reloadEgoFooterView:(NSArray *)resourceInfos totalNum:(int)totalNum egoView:(EGORefreshTableHeaderView *)footView
{
    BOOL returnResult = NO;
    if (resourceInfos.count % totalNum == 0 && resourceInfos.count > 0) {
        footView.delegate = self;
        footView.center = CGPointMake(footView.center.x, self.scrollView.contentSize.height + footView.frame.size.height/2);
        returnResult = YES;
    }
    return returnResult;
}

#pragma mark EgoHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerGetMore:(EGORefreshTableHeaderView*)view
{
    NSLog(@"egoRefreshTableHeaderDidTriggerGetMore !!");
    if (_leftNum > 0) {
        [self getMoreData:SearchNum-_leftNum];
        _getMoreDataNum = SearchNum - _leftNum;
    } else {
        _getMoreDataNum = SearchNum;
        [self getMoreData:SearchNum];
    }
}


@end
