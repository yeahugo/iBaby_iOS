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

@interface AiDataManager : NSObject
{
    NSInteger _babyId;
    
    ReqHead *_reqHead;
    
    NSOperationQueue *_queue;
}

@property (nonatomic, copy) Completion completion;

-(id)initWithBabyId:(NSInteger)babyId;

-(void)getRecommendWithCompletion:(void (^)(NSArray *, NSError *))completion;

-(void)searchWithKeyWords:(NSString *)keyWords completion:(void (^)(NSArray *resultArray,NSError *error))completion;
@end
