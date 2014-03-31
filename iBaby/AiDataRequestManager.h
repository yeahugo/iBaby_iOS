//
//  AiDataManager.h
//  iBaby
//
//  Created by yeahugo on 14-3-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shy_client_server.h"
#import "AiDefine.h"

typedef void (^Completion)(NSArray *resultArray,NSError *error);

@interface AiDataRequestManager : NSObject
{
    int _babyId;
    
    ReqHead *_reqHead;
    
    NSOperationQueue *_queue;
    
    int _reConnectNum;
}

@property (nonatomic, copy) Completion completion;

@property (nonatomic, assign) int babyId;

+ (AiDataRequestManager *)shareInstance;

-(id)initWithBabyId:(int)babyId;

-(void)requestRecommendWithCompletion:(void (^)(NSArray *, NSError *))completion;

-(void)requestSearchWithKeyWords:(NSString *)keyWords startId:(NSNumber *)startId completion:(void (^)(NSArray *resultArray,NSError *error))completion;
@end
