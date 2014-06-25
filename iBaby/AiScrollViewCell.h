//
//  AiScrollViewCell.h
//  iBaby
//
//  Created by yeahugo on 14-6-23.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shy.h"
#import "AiScrollView.h"

@interface AiScrollViewCell : UIView

//@property (nonatomic, copy) AiVideoObject *aiVideoObject;

@property (nonatomic, strong) ResourceInfo *resourceInfo;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) AiScrollView *scrollView;

@property (nonatomic, assign) kViewCellType viewCellType;

@property (nonatomic, strong) UIImageView *backgroundView;

-(void)onClickButton:(UIButton *)button;

-(void)reloadResourceInfo;

//-(id)initWithVideoObject:(AiVideoObject *)videoObject;

-(id)initWithVideoResource:(ResourceInfo *)resourceInfo;

-(id)initWithFrame:(CGRect)frame cellType:(kViewCellType)viewCellType;

-(void)setHightLightScrollViewCell;
@end
