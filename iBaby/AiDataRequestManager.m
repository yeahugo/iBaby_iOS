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

-(void)doSearch:(NSDictionary *)info
{
    NSString *keyWords = [info valueForKey:@"keyWords"];
    int startId = [[info valueForKeyPath:@"startId"] intValue];
    Completion completion = [info valueForKey:@"completion"];
    SearchReq *searchReq = [[SearchReq alloc] initWithHead:_reqHead searchKeys:keyWords resourceType:0 startId:startId recordNum:SearchNum];
    @try {
        NSLog(@"doSearch with %@",keyWords);
        SearchResp *resp = [[AiThriftManager shareInstance].resourceClient search:searchReq];
        
        if (resp.resCode == 200) {
            NSArray * resultArray = resp.result;
            completion(resultArray,nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
            completion(nil,error);
        }
        
        _reConnectNum = 0;
    }
    @catch (NSException *exception) {
        _reConnectNum ++;
        if (_reConnectNum < 3) {
            [[AiThriftManager shareInstance] reConnect];
            [self doSearch:info];
        }
        NSLog(@"exception is %@",exception);
    }
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

-(void)requestSearchWithKeyWords:(NSString *)keyWords startId:(NSNumber *)startId completion:(void (^)(NSArray *, NSError *))completion
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:keyWords,@"keyWords",startId,@"startId",[completion copy],@"completion",nil];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doSearch:) object:dictionary];
    [_queue addOperation:operation];
}
@end
