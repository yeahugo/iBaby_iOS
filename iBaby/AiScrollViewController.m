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

@implementation AiScrollViewController

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords
{
    _songListArray = [[NSMutableArray alloc] init];
    self.songListArray = _songListArray;
    if (self) {
        _startId = 0;
        AiScrollView *scrollView = [[AiScrollView alloc] initWithFrame:frame];
        scrollView.delegate = self;
        scrollView.scrollViewController = self;
        self.scrollView = scrollView;
        self.scrollView.backgroundColor = [UIColor clearColor];
        _songListArray = [[NSMutableArray alloc] init];
        if (keyWords) {
            [self clickKeyWords:keyWords];
        }
    }
    return self;
}

-(void)clickKeyWords:(NSString *)keyWords
{
    [_songListArray removeAllObjects];
    self.keyWords = keyWords;
    AiDataRequestManager *dataManager = [AiDataRequestManager shareInstance];
    [dataManager requestSearchWithKeyWords:keyWords startId:[NSNumber numberWithInt:_startId] completion:^(NSArray *resultArray,NSError *error){
        if (error == nil) {
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
    [dataManager requestSearchWithKeyWords:self.keyWords startId:[NSNumber numberWithInt:_startId] completion:^(NSArray *resultArray,NSError *error){
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
                NSLog(@"videoType is %d resourceInfo is %d serialId is %@ sectionNum is %d",videoObject.videoType,resourceInfo.fileType,resourceInfo.serialId,videoObject.totalSectionNum);
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
