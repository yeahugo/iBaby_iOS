//
//  AiScrollView.h
//  iBaby
//
//  Created by yeahugo on 14-5-10.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AiVideoObject.h"
#import "SwipeView.h"
#import "EGORefreshTableHeaderView.h"

@class AiScrollViewController;

@interface AiScrollView : UIScrollView
<EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
{
    EGORefreshTableHeaderView * _egoFooterView;
    int _cellHeight;
    int _cellOffSetY;
    int _cellOffSetX;
    int _leftNum;
    int _getMoreDataNum;
}

@property (nonatomic, assign) kTagViewType viewType;

@property (nonatomic, assign) kSearchViewType searchViewType;

@property (nonatomic, strong) NSMutableArray * videoDatas;

@property (nonatomic, strong) NSMutableArray * normalDatas;

@property (nonatomic, strong) NSArray *leftDatas;  //第一次没有显示完的数据

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, assign) AiScrollViewController * scrollViewController;

@property (nonatomic, assign) int pageCount;

@property (nonatomic, strong) UIButton *songButton;

@property (nonatomic, strong) UIButton *allButton;

@property (nonatomic, strong) UIButton *cattonButton;

@property (nonatomic, strong) UIButton *videoButton;

@property (nonatomic, strong) UIImageView *chooseView;

-(void)setAiVideoObjects:(NSArray *)aiVideoObjects;

-(void)addAiVideoObjects:(NSArray *)aiVideoObjects;

-(void)reloadData;
@end

@interface AiAlbumView : UIView

@property (nonatomic, strong) IBOutlet UILabel *albumTitle;

@end

@interface AiSearchRecommendView : UIView

@property (nonatomic, strong) IBOutlet UILabel *albumTitle;

@property (nonatomic, strong) IBOutlet UIImageView *albumImage;

@property (nonatomic, strong) IBOutlet UILabel *introText;

@property (nonatomic, strong) AiVideoObject *videoObject;

@property (nonatomic, copy) NSString *keyWords;

-(IBAction)playVideo:(id)sender;
@end

@interface AiScrollViewCell : UIView

@property (nonatomic, copy) AiVideoObject *aiVideoObject;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) AiScrollView *scrollView;

@property (nonatomic, assign) kViewCellType viewCellType;

@property (nonatomic, strong) UIImageView *backgroundView;

-(void)onClickButton:(UIButton *)button;

-(id)initWithVideoObject:(AiVideoObject *)videoObject;

-(id)initWithFrame:(CGRect)frame cellType:(kViewCellType)viewCellType;

-(void)setHightLightScrollViewCell;
@end