//
//  AiScrollViewController.m
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiScrollViewController.h"
#import "AiDataRequestManager.h"
#import "AiDataBaseManager.h"
#import "AiWaitingView.h"

@implementation AiScrollViewController

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords
{
    if (self) {
        _songListArray = [[NSMutableArray alloc] init];
        self.songListArray = _songListArray;
        self.viewType = kTagViewTypeSearch;

        _startId = 0;
        AiScrollView *scrollView = [[AiScrollView alloc] initWithFrame:frame];
        scrollView.viewType = kTagViewTypeSearch;
        scrollView.delegate = self;
        scrollView.scrollViewController = self;
        scrollView.pageCount = SearchNum;
        scrollView.searchViewType = kSearchViewTypeAll;
        self.scrollView = scrollView;
        _songListArray = [[NSMutableArray alloc] init];
        
        if (keyWords) {
            self.resourceType = -1;
            [self clickKeyWords:keyWords resourceType:-1];
        }
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame recommend:(int)resourceType
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
        self.scrollView.scrollViewController = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        _songListArray = [[NSMutableArray alloc] init];
        [self getRecommendResource:resourceType];
    }
    return self;
}

-(void)getRecommendResourceType
{
    [self getRecommendResource:self.resourceType];
}

-(id)initWithFrame:(CGRect)frame serialId:(NSString *)serialId completion:(void (^)(NSArray * resultArray, NSError * error))completion
{
    _songListArray = [[NSMutableArray alloc] init];
    self.songListArray = _songListArray;
    self.viewType = kTagViewTypeAlbum;
    if (self) {
        _startId = 0;
        self.serialId = serialId;
        AiScrollView *scrollView = [[AiScrollView alloc] initWithFrame:frame];
        scrollView.viewType = kTagViewTypeAlbum;
        scrollView.delegate = self;
        scrollView.scrollViewController = self;
        scrollView.pageCount = SearchNum;
        self.scrollView = scrollView;
        self.scrollView.backgroundColor = [UIColor clearColor];
        _songListArray = [[NSMutableArray alloc] init];
        void (^copyCompletion)(NSArray *, NSError *)  = [completion copy];
        [self getAlbumResource:serialId completion:copyCompletion];
    }
    return self;
}

-(void)getAlbumResource:(NSString *)serialId completion:(void (^)(NSArray *, NSError *))viewCompletion
{
    [_songListArray removeAllObjects];
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestAlbumWithSerialId:serialId startId:_startId recordNum:SearchNum videoTitle:@"" completion:^(NSArray *resultArray, NSError *error) {
        if (error == nil) {
            _startId = _startId + (int)resultArray.count;
            NSMutableArray * saveSongArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < resultArray.count; i++) {
                ResourceInfo * resourceInfo = [resultArray objectAtIndex:i];
                AiVideoObject * videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                [saveSongArray addObject:videoObject];
            }
            [_songListArray addObjectsFromArray:saveSongArray];
            [self.scrollView setAiVideoObjects:_songListArray];   
        }
        if (viewCompletion) {
            viewCompletion(resultArray,error);
        }
    }];
}

-(void)getRecommendResource:(int)resourceType
{
    [_songListArray removeAllObjects];
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestRecommendWithType:resourceType startId:_startId completion:^(NSArray *resultArray,NSError *error){
        [AiWaitingView dismiss];
        if (error == nil) {
            _startId = _startId + (int)resultArray.count;
            NSMutableArray * saveSongArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < resultArray.count; i++) {
                ResourceInfo * resourceInfo = [resultArray objectAtIndex:i];
                AiVideoObject * videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                [saveSongArray addObject:videoObject];
            }
            [_songListArray addObjectsFromArray:saveSongArray];
            [self.scrollView setAiVideoObjects:_songListArray];
        } else {
            NSLog(@"error is %@",error);
        }
    }];
}

-(void)clickKeyWords:(NSString *)keyWords resourceType:(int)resourceType
{
    [_songListArray removeAllObjects];
    if (keyWords) {
        self.keyWords = keyWords;
    }
    _startId = 0;
    self.resourceType = resourceType;
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestSearchWithKeyWords:self.keyWords startId:[NSNumber numberWithInt:_startId] resourceType:resourceType completion:^(NSArray *resultArray,NSError *error){
        [AiWaitingView dismiss];
        if (error == nil) {
            if (resultArray.count == 0) {
                UIImageView *noResultImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_results"]];
                noResultImage.center = CGPointMake(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
                [self.scrollView addSubview:noResultImage];
                [self.scrollView setAiVideoObjects:_songListArray];
                return;
            }
            
            _startId = _startId + resultArray.count;
            NSMutableArray * saveSongArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < resultArray.count; i++) {
                ResourceInfo * resourceInfo = [resultArray objectAtIndex:i];
                AiVideoObject * videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                [saveSongArray addObject:videoObject];
            }
            [_songListArray addObjectsFromArray:saveSongArray];
            [self.scrollView setAiVideoObjects:_songListArray];
        }
    }];
}

-(void)getMoreData
{
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    if (self.scrollView.viewType == kTagViewTypeSearch) {
        [dataManager requestSearchWithKeyWords:self.keyWords startId:[NSNumber numberWithInt:_startId] resourceType:self.resourceType completion:^(NSArray *resultArray,NSError *error){
            if (error == nil) {
                _startId = _startId + resultArray.count;
                NSMutableArray * saveSongArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < resultArray.count; i++) {
                    ResourceInfo * resourceInfo = [resultArray objectAtIndex:i];
                    AiVideoObject * videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                    [saveSongArray addObject:videoObject];
                }
                NSLog(@"saveSongArray count is %d",saveSongArray.count);
                [_songListArray addObjectsFromArray:saveSongArray];
                [self.scrollView addAiVideoObjects:saveSongArray];
            }
        }];
    }
    if (self.scrollView.viewType == kTagViewTypeIndex) {
        [dataManager requestRecommendWithType:self.resourceType startId:_startId completion:^(NSArray *resultArray, NSError *error) {
            if (error == nil) {
                NSLog(@"start id is %d",_startId);
                _startId = _startId + resultArray.count;
                NSMutableArray * saveSongArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < resultArray.count; i++) {
                    ResourceInfo * resourceInfo = [resultArray objectAtIndex:i];
                    AiVideoObject * videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                    if (videoObject.status == RESOURCE_STATUS_NORMAL) {
                        [saveSongArray addObject:videoObject];
                    }
                }
                [_songListArray addObjectsFromArray:saveSongArray];
                NSLog(@"add song is %d",saveSongArray.count);
                [self.scrollView addAiVideoObjects:saveSongArray];
            }
        }];
    }
    if (self.scrollView.viewType == kTagViewTypeAlbum) {
        [dataManager requestAlbumWithSerialId:self.serialId startId:_startId recordNum:SearchNum videoTitle:@"" completion:^(NSArray *resultArray, NSError *error) {
            if (error == nil) {
                _startId = _startId + resultArray.count;
                NSMutableArray * saveSongArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < resultArray.count; i++) {
                    ResourceInfo * resourceInfo = [resultArray objectAtIndex:i];
                    AiVideoObject * videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                    [saveSongArray addObject:videoObject];
                }
                [_songListArray addObjectsFromArray:saveSongArray];
                [self.scrollView addAiVideoObjects:saveSongArray];
            }
        }];
    }
    if (self.scrollView.viewType == kTagViewTypeHistory) {
        [[AiDataBaseManager shareInstance] getMoreVideoListWithType:kDatabaseTypeHistory completion:^(NSArray *videoList, NSError *error) {
            if (error == nil) {
                [self.scrollView addAiVideoObjects:videoList];
            }
        }];
    }
    if (self.scrollView.viewType == kTagViewTypeFavourite) {
        [[AiDataBaseManager shareInstance] getMoreVideoListWithType:kDatabaseTypeFavourite completion:^(NSArray *videoList, NSError *error) {
            if (error == nil) {
                [self.scrollView addAiVideoObjects:videoList];
            }
        }];
    }
}

-(void)saveVideoObjects:(NSArray *)resultArray saveArray:(NSMutableArray *)saveArray error:(NSError *)error
{
    if (error == nil) {
        long count = resultArray.count/ShowNum;
        for (int i = 0 ; i <= count; i++) {
            NSMutableArray * newArray = [[NSMutableArray alloc] init];
            long num = (i+1)*ShowNum < resultArray.count ? (i+1)*ShowNum:resultArray.count;
            for (int j = i*ShowNum; j < num; j++) {
                ResourceInfo *resourceInfo = [resultArray objectAtIndex:j];
                AiVideoObject *videoObject = [[AiVideoObject alloc] initWithResourceInfo:resourceInfo];
                [newArray addObject:videoObject];
            }
            if (newArray.count > 0) {
                [saveArray addObject:newArray];
            }
        }
    } else{
        NSLog(@"error is %@",error);
    }
}

@end
