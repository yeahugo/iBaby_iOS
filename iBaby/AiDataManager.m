//
//  AiDataManager.m
//  iBaby
//
//  Created by yeahugo on 14-3-27.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiDataManager.h"
#import "AiThriftManager.h"

@implementation AiDataManager

-(id)initWithBabyId:(NSInteger)babyId
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
    Completion completion = [info valueForKey:@"completion"];
    SearchReq *searchReq = [[SearchReq alloc] initWithHead:_reqHead searchKeys:keyWords resourceType:0 startId:0 recordNum:SearchNum];
    SearchResp *resp = [[AiThriftManager shareInstance].resourceClient search:searchReq];
    if (resp.resCode == 200) {
        NSArray * resultArray = resp.result;
        completion(resultArray,nil);
    } else {
        NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
        completion(nil,error);
    }
}

-(void)getRecommend
{
    RecommendReq * recommendReq = [[RecommendReq alloc] initWithHead:_reqHead startId:0 recordNum:RecommendNum];
    RecommendResp *resp = [[AiThriftManager shareInstance].resourceClient getRecommendResources:recommendReq];
    if (resp.resCode == 200) {
        NSArray * resultArray = resp.recommends;
        self.completion(resultArray,nil);
    } else {
        NSError *error = [NSError errorWithDomain:@"server error" code:resp.resCode userInfo:nil];
        self.completion(nil,error);
    }
}

-(void)getRecommendWithCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getRecommend) object:nil];
    self.completion = completion;
    [_queue addOperation:operation];
}

-(void)searchWithKeyWords:(NSString *)keyWords completion:(void (^)(NSArray *, NSError *))completion
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:keyWords,@"keyWords",[completion copy],@"completion",nil];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doSearch:) object:dictionary];
    [_queue addOperation:operation];
}
@end
