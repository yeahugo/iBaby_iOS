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
//#import "AiGridViewController.h"

typedef enum {
    kDataSourceTypeWeb,
    kDataSourceTypeDatabase,
} kDataSourceType;

@interface AiScrollViewController : NSObject<UIScrollViewDelegate>
{
    int _startId;
}

@property (nonatomic, strong) NSMutableArray *songListArray;

@property (nonatomic, assign) kTagButtonType videoType;

@property (nonatomic, assign) kDataSourceType sourceType;

@property (nonatomic, assign) kTagViewType viewType;

@property (nonatomic, assign) int resourceType;

@property (nonatomic, copy) NSString *serialId;

@property (nonatomic, strong) AiScrollView *scrollView;

@property (nonatomic, copy) NSString *keyWords;

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords;

-(id)initWithFrame:(CGRect)frame recommend:(int)resourceType;

-(id)initWithFrame:(CGRect)frame serialId:(NSString *)serialId completion:(void (^)(NSArray * resultArray, NSError * error))completion;

-(void)clickKeyWords:(NSString *)keyWords resourceType:(int)resourceType;

-(void)getRecommendResourceType;

-(void)getMoreData;

@end
