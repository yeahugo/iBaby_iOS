//
//  AiDataManager.m
//  iBaby
//
//  Created by yeahugo on 14-3-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiDataRequestManager.h"
#import "AiThriftManager.h"

@implementation AiDataRequestManager

+ (AiDataRequestManager *)shareInstance {
    static AiDataRequestManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

-(id)init{
    self = [super init];
    if (self) {
        _reConnectNum = 0;
        _queue = [[NSOperationQueue alloc] init];
//        _queue = [NSOperationQueue currentQueue];
        [_queue setMaxConcurrentOperationCount:1];
        _reqHead = [[ReqHead alloc] initWithBabyId:123 guid:@"123" version:@"1.0"];
    }
    return self;
}

-(void)setBabyId:(int)babyId
{
    _reqHead = [[ReqHead alloc] initWithBabyId:babyId guid:@"123" version:@"1.0"];
}

-(id)initWithBabyId:(int)babyId
{
    self = [super init];
    if (self) {
        _babyId = babyId;
        _reqHead = [[ReqHead alloc] initWithBabyId:_babyId guid:@"123" version:@"1.0"];
        
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void)getRecommend
{
    RecommendReq * recommendReq = [[RecommendReq alloc] initWithHead:_reqHead startId:0 recordNum:RecommendNum];
    @try {
        RecommendResp *resp = [[AiThriftManager shareInstance].resourceClient getRecommendResources:recommendReq];
        if (resp.resCode == 200) {
            NSArray * resultArray = resp.recommends;
            self.completion(resultArray,nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
            self.completion(nil,error);
        }
    }
    @catch (NSException *exception) {
        [[AiThriftManager shareInstance] reConnect];
        [self getRecommend];
        NSLog(@"exception is %@",exception);
    }
}

-(void)requestRecommendWithCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getRecommend) object:nil];
    self.completion = completion;
    [_queue addOperation:operation];
}

-(void)doSearchWithRequest:(SearchReq *)searchReq completion:(void (^)(NSArray *, NSError *))completion
{
    NSLog(@"doSearchWithRequest with keyWords is %@",searchReq);
    SearchResp *resp = [[AiThriftManager shareInstance].resourceClient search:searchReq];
        
    if (resp.resCode == 200) {
        NSArray * resultArray = resp.result;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(resultArray,nil);
        });
    } else {
        NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil,error);
        });
    }
}

-(void)requestSearchWithKeyWords:(NSString *)keyWords startId:(NSNumber *)startId completion:(void (^)(NSArray *, NSError *))completion
{
    [_queue addOperationWithBlock:^(void){
        SearchReq *searchReq = [[SearchReq alloc] initWithHead:_reqHead searchKeys:keyWords resourceType:0 startId:[startId integerValue] recordNum:SearchNum];
        @try {
            [self doSearchWithRequest:searchReq completion:completion];
        }
        @catch (NSException *exception) {
            [[AiThriftManager shareInstance] reConnect];
            NSLog(@"exception is %@",exception);
            @try {
                [self doSearchWithRequest:searchReq completion:completion];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
        }

    }];
}
@end
