//
//  AiGridViewController.h
//  iBaby
//
//  Created by yeahugo on 14-3-30.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiGridView.h"

@interface AiGridViewController : NSObject<UIScrollViewDelegate,SwipeViewDataSource,SwipeViewDelegate>

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords;

-(void)clickKeyWords:(NSString *)keyWords;

@property (nonatomic, strong) AiSwipeView *swipeView;

@property (nonatomic, copy) NSString *keyWords;

@end