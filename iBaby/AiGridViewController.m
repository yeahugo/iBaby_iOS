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
    NSMutableArray *_songListArray;
}
@end

@implementation AiGridViewController

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords
{
    self = [super init];
    if (self) {
        _scrollNum = 0;
        _songListArray = [[NSMutableArray alloc] init];
        AiGridView *gridView = [[AiGridView alloc] initWithFrame:frame];
        gridView.delegate = self;
        gridView.backgroundColor = [UIColor clearColor];
        self.gridView = gridView;
        
        [self clickKeyWords:keyWords];
    }
    return self;
}

-(void)clickKeyWords:(NSString *)keyWords
{
    [_songListArray removeAllObjects];
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    NSMutableArray *songArray = [[NSMutableArray alloc] init];
    [dataManager requestSearchWithKeyWords:keyWords startId:[NSNumber numberWithInt:0] completion:^(NSArray *resultArray ,NSError *error){
        
        [self saveVideoObjects:resultArray saveArray:songArray error:error];
        [_songListArray addObject:songArray];
        [self.gridView setVideoObjects:songArray];
        if (resultArray.count == SearchNum) {
            [dataManager requestSearchWithKeyWords:keyWords startId:[NSNumber numberWithInt:SearchNum] completion:^(NSArray *resultArray, NSError *error) {
                NSMutableArray * nextSongArray = [[NSMutableArray alloc] init];
                [self saveVideoObjects:resultArray saveArray:nextSongArray error:error];
                [_songListArray addObject:nextSongArray];
            }];
        }
    }];
}

#pragma UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > ScrollOffSet/2) {
        NSLog(@"chang to right");
    }
    else if (scrollView.contentOffset.x < -ScrollOffSet/2) {
        NSLog(@"change to left");
    }
    else {
        if (scrollView.contentOffset.y > ScrollOffSet/2) {
            self.gridView.footerArrowView.hidden = NO;
            if (scrollView.contentOffset.y > ScrollOffSet) {
                [self.gridView transFormArrow:self.gridView.footerArrowView];
            }
            if (scrollView.contentOffset.y < ScrollOffSet) {
                [self.gridView recover:self.gridView.footerArrowView];
            }
            self.gridView.headerArrowView.hidden = YES;
        } else if(scrollView.contentOffset.y < -ScrollOffSet/2) {
            self.gridView.headerArrowView.hidden = NO;
            if (scrollView.contentOffset.y < ScrollOffSet) {
                [self.gridView transFormArrow:self.gridView.headerArrowView];
            }
            if (scrollView.contentOffset.y < ScrollOffSet) {
                [self.gridView recover:self.gridView.headerArrowView];
            }
            self.gridView.footerArrowView.hidden = YES;
        } else{
            self.gridView.headerArrowView.hidden = YES;
            self.gridView.footerArrowView.hidden = YES;
        }
    }
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"count is %d",[[_songListArray objectAtIndex:_scrollNum] count]);
    if (scrollView.contentOffset.y > ScrollOffSet ) {
        if ([[_songListArray objectAtIndex:_scrollNum] count] == SearchNum)
        {
            _scrollNum ++;
            
            if (_songListArray.count -1 >= _scrollNum) {
                NSMutableArray *songArray = [_songListArray objectAtIndex:_scrollNum];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.gridView setVideoObjects:songArray];
                    [self.gridView setContentOffset:CGPointMake(0, 0) animated:YES];
                });
                
                if (_songListArray.count -1 == _scrollNum) {
                    NSLog(@"request next page!!");
                    NSMutableArray *newSongArray = [[NSMutableArray alloc] init];
                    int startId = _scrollNum * SearchNum;
                    [[AiDataRequestManager shareInstance] requestSearchWithKeyWords:@"儿歌" startId:[NSNumber numberWithInt:startId] completion:^(NSArray *resultArray ,NSError *error){
                        [self saveVideoObjects:resultArray saveArray:newSongArray error:error];
                        [_songListArray addObject:newSongArray];
                    }];
                }
            } else {
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.gridView setContentOffset:CGPointMake(0, 0) animated:YES];
            });
        }
    } else if (scrollView.contentOffset.y < -ScrollOffSet && _scrollNum > 0){
        _scrollNum --;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *songArray = [_songListArray objectAtIndex:_scrollNum];
            [self.gridView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self.gridView setVideoObjects:songArray];
        });
    }
    NSLog(@"scrollNum is %d",_scrollNum);
}

@end
