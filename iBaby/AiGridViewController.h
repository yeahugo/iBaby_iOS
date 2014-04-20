//
//  AiGridViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-30.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiGridView.h"

typedef enum {
    kDataSourceTypeWeb,
    kDataSourceTypeDatabase,
} kDataSourceType;

@interface AiGridViewController : NSObject<UIScrollViewDelegate,SwipeViewDataSource,SwipeViewDelegate>

@property (nonatomic, strong) NSMutableArray *songListArray;

@property (nonatomic, assign) kTagButtonType videoType;

@property (nonatomic, assign) kDataSourceType sourceType;

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords;

-(void)clickKeyWords:(NSString *)keyWords;

@property (nonatomic, strong) AiSwipeView *swipeView;

@property (nonatomic, copy) NSString *keyWords;

@end
