//
//  AiGridViewController.m
//  iBaby
//
//  Created by yeahugo on 14-3-30.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiGridViewController.h"
#import "AiDataRequestManager.h"

@interface AiGridViewController()
{
    int _scrollNum;
    int _swipeItemNum;
    NSMutableArray *_songListArray;
}
@end

@implementation AiGridViewController

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords
{
    self = [super init];
    if (self) {
        _scrollNum = 0;
        _swipeItemNum = 1;
        _songListArray = [[NSMutableArray alloc] init];
        AiSwipeView *swipeView = [[AiSwipeView alloc] initWithFrame:frame];
        swipeView.delegate = self;
        swipeView.dataSource = self;
        swipeView.backgroundColor = [UIColor clearColor];
        self.swipeView = swipeView;
        
        [self clickKeyWords:keyWords];
    }
    return self;
}

-(void)clickKeyWords:(NSString *)keyWords
{
    [_songListArray removeAllObjects];
    self.keyWords = keyWords;
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    NSMutableArray *songArray = [[NSMutableArray alloc] init];
    [dataManager requestSearchWithKeyWords:keyWords startId:[NSNumber numberWithInt:0] completion:^(NSArray *firstResultArray ,NSError *error){
        
        [self saveVideoObjects:firstResultArray saveArray:songArray error:error];
//        [_songListArray addObject:songArray];
        [_songListArray addObjectsFromArray:songArray];
        [self.swipeView reloadData];
        
        if (firstResultArray.count == SearchNum) {
            NSLog(@"resultArray is %@",firstResultArray);
            [dataManager requestSearchWithKeyWords:keyWords startId:[NSNumber numberWithInt:SearchNum] completion:^(NSArray *resultArray, NSError *error) {
                NSMutableArray * nextSongArray = [[NSMutableArray alloc] init];
                [self saveVideoObjects:resultArray saveArray:nextSongArray error:error];
                [_songListArray addObjectsFromArray:nextSongArray];
                [self.swipeView reloadData];
                
                if (resultArray.count == SearchNum) {
                    [dataManager requestSearchWithKeyWords:keyWords startId:[NSNumber numberWithInt:SearchNum * 2] completion:^(NSArray *resultArray, NSError *error) {
                        NSMutableArray * thirdSongArray = [[NSMutableArray alloc] init];
                        [self saveVideoObjects:resultArray saveArray:thirdSongArray error:error];
                        [_songListArray addObjectsFromArray:nextSongArray];
                        [self.swipeView reloadData];}];
                }
            }];
        }
    }];
}

#pragma SwipeViewDelegate
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    if (swipeView.currentItemIndex + 2 == [_songListArray count] && [[_songListArray objectAtIndex:_songListArray.count - 2] count] == SearchNum) {
        [[AiDataRequestManager shareInstance] requestSearchWithKeyWords:self.keyWords startId:[NSNumber numberWithInt:SearchNum * _songListArray.count] completion:^(NSArray *resultArray, NSError *error) {
            NSMutableArray * nextSongArray = [[NSMutableArray alloc] init];
            [self saveVideoObjects:resultArray saveArray:nextSongArray error:error];
            [_songListArray addObject:nextSongArray];
            [self.swipeView reloadData];
        }];
    }
}

#pragma SwipeViewDataSource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    NSLog(@"_swipeItemNum is %d",_swipeItemNum);
    return [_songListArray count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    AiGridView * gridView = [[AiGridView alloc] initWithFrame:swipeView.frame];
    if (_songListArray.count > index) {
        NSArray * songArray = [_songListArray objectAtIndex:index];
        [gridView setVideoObjects:songArray];
    }
    return gridView;
}


-(void)saveVideoObjects:(NSArray *)resultArray saveArray:(NSMutableArray *)saveArray error:(NSError *)error
{
    if (error == nil) {
        int count = resultArray.count/ShowNum;
        for (int i = 0 ; i <= count; i++) {
            NSMutableArray * newArray = [[NSMutableArray alloc] init];
            int num = (i+1)*ShowNum < resultArray.count ? (i+1)*ShowNum:resultArray.count;
            for (int j = i*ShowNum; j < num; j++) {
                AiVideoObject *videoObject = [[AiVideoObject alloc] init];
                ResourceInfo *resourceInfo = [resultArray objectAtIndex:j];
                videoObject.title = resourceInfo.title;
                videoObject.imageUrl = resourceInfo.img;
                videoObject.vid = resourceInfo.url;
                videoObject.sourceType = resourceInfo.resourceType;
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
