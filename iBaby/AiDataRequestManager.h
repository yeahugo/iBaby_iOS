//
//  AiDataManager.h
//  iBaby
//
//  Created by yeahugo on 14-3-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shy.h"
#import "AiDefine.h"

typedef void (^Completion)(NSArray *resultArray,NSError *error);

@interface AiDataRequestManager : NSObject
{
    int _babyId;
    
    ReqHead *_reqHead;
        
    int _reConnectNum;
    
    int _searchKeyVer;
}

@property (nonatomic, strong) ReqHead *reqHead;

@property (nonatomic, assign) int babyId;

@property (nonatomic, assign) int isYoukuUseUrl;

@property (nonatomic, copy) NSString *wuliuAppkey;

@property (nonatomic, copy) NSString *wuliuSecret;

@property (nonatomic, copy) NSString *youkuAppkey;

@property (nonatomic, copy) NSString *youkuSecret;

@property (nonatomic, assign) int isReportFlag;

@property (nonatomic, assign) int searchKeyVer;

@property (nonatomic, assign) int searchDefaultVer;

@property (nonatomic, strong) NSOperationQueue *queue;

+ (AiDataRequestManager *)shareInstance;

-(void)requestAlbumWithSerialId:(NSString *)serialId startId:(int)startId  recordNum:(int)recordNum videoTitle:(NSString *)videoTitle completion:(void (^)(NSArray *resultArray,NSError *error))completion;

-(void)requestRecommendWithType:(int)resourceType startId:(int)startId totalNum:(int)totalNum completion:(void (^)(NSArray *resultArray , NSError * error))completion;

-(void)requestSearchWithKeyWords:(NSString *)keyWords startId:(NSNumber *)startId resourceType:(int)resourceType completion:(void (^)(NSArray *resultArray,NSError *error))completion;

-(void)requestSearchRecommend:(void (^)(NSArray * resultArray,NSError *error))completion;

-(void)requestReportWithString:(NSString *)reportString completion:(void (^)(NSArray *resultArray , NSError * error))completion;

@end
