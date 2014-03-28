//
//  AiBackgroundView.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class AiGridViewCell;
//
//@protocol AiGridViewDataSource <NSObject>
//
//-(NSInteger)gridViewNumber;
//
//-(AiGridViewCell *)cellForRowWithIndex;
//
//@end

#import "AiVideoObject.h"

@interface AiGridViewCell : UIView

@property (nonatomic, strong) AiVideoObject *aiVideoObject;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, strong) UILabel *titleLabel;

//@property (nonatomic, assign) UIViewController *backgroundViewController;

@end

@interface AiGridView : UIView

@property (nonatomic, strong) NSArray * videoDatas;

-(void)setVideoObjects:(NSArray *)videoObjects;

@end
