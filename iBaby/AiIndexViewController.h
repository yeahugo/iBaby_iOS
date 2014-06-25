//
//  AiScrollViewController.h
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiDefine.h"
#import "AiScrollView.h"

//typedef enum {
//    kDataSourceTypeWeb,
//    kDataSourceTypeDatabase,
//} kDataSourceType;

@interface AiIndexViewController : NSObject
<UIScrollViewDelegate,AiScrollViewDelegate,EGORefreshTableHeaderDelegate>
{
    int _leftNum;
    int _getMoreDataNum;
}

@property (nonatomic, strong) NSMutableArray *songListArray;

@property (nonatomic, strong) NSArray *leftDatas;

@property (nonatomic, assign) kTagButtonType videoType;

@property (nonatomic, assign) kTagViewType viewType;

@property (nonatomic, assign) int resourceType;

@property (nonatomic, strong) AiScrollView *scrollView;

@property (nonatomic, assign) int startId;

-(id)initWithFrame:(CGRect)frame recommend:(int)resourceType completion:(void (^)(void))completion;

-(void)getRecommendResource:(int)resourceType completion:(void (^)(void))completion;

@end
