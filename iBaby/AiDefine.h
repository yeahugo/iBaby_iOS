//
//  AiDefine.h
//  iBaby
//
//  Created by yeahugo on 14-3-26.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#ifndef iBaby_AiDefine_h
#define iBaby_AiDefine_h

typedef enum {
    kTagButtonTypeSong,
    kTagButtonTypeCatoon,
    kTagButtonTypeVideo
} kTagButtonType;

typedef enum {
    kViewCellTypeHot,
    kViewCellTypeRecommend,
    kViewCellTypeNormal,
    kViewCellTypeSearchRecommend
}kViewCellType;

typedef enum {
    kTagViewTypeIndex,
    kTagViewTypeSearch,
    kTagViewTypeHistory,
    kTagViewTypeFavourite,
    kTagViewTypeAlbum
} kTagViewType;

#define ResponseCodeSuccess 0

#define kTagVideoCellStartIndex 1000

#define AI_HOST_IP @"115.28.213.143"

#define UmengAppkey @"537d712556240b75fb0a2645"

//#define AI_HOST_IP @"10.0.2.15"

//#define AI_HOST_PORT 9090
#define AI_HOST_PORT 9013

#define ShowNum 12

#define SearchNum 12*3

#define AlbumNum 35

#define RecommendNum SearchNum

#define ColNum 4

#define RowNum 2

#define ScrollOffSet 100

#define VideoTypeNum 3

#define HistoryNum 12*3

#define VERSION @"1.0"

#endif
