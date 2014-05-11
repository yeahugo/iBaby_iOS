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
#import "AiGridViewController.h"

//typedef enum {
//    kDataSourceTypeWeb,
//    kDataSourceTypeDatabase,
//} kDataSourceType;

@interface AiScrollViewController : NSObject<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *songListArray;

@property (nonatomic, assign) kTagButtonType videoType;

@property (nonatomic, assign) kDataSourceType sourceType;

-(id)initWithFrame:(CGRect)frame keyWords:(NSString *)keyWords;

-(void)clickKeyWords:(NSString *)keyWords;

@property (nonatomic, strong) AiScrollView *scrollView;

@property (nonatomic, copy) NSString *keyWords;

@end
