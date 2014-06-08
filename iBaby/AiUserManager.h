//
//  AiUserManager.h
//  iBaby
//
//  Created by yeahugo on 14-5-14.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiThriftManager.h"

@interface AiUserManager : NSObject

@property (nonatomic, copy) NSString *passwd;

@property (nonatomic, assign) int babyId;

@property (nonatomic, copy) NSString *openUdid;

+ (AiUserManager *)shareInstance;

-(void)userRegistWithCompletion:(void (^)(RegisterResp *result , NSError * error))completion;

-(void)userLogin:(void (^)(int result))completion;

-(void)updateConfig:(void(^)(UserConfig *config))completion;

-(void)getSearchSuggestKeys:(void (^)(int result))completion;

+ (NSString *)md5Value:(NSString *)string;
@end
