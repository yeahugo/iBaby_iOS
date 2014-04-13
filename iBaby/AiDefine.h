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
    kTagPlaySourceTypeYouku,
    kTagPlaySourceType56,
} kTagPlaySourceType;

#define kTagVideoCellStartIndex 1000

#define AI_HOST_IP @"115.28.213.143"

#define AI_HOST_PORT 9090

#define ShowNum 12

#define SearchNum (12*3)

#define RecommendNum 20

#define ColNum 4

#define RowNum 3

#define ScrollOffSet 100

#define VideoTypeNum 3

#define HistoryNum 12

#endif
