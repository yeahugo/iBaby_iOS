//
//  AiUserManager.m
//  iBaby
//
//  Created by yeahugo on 14-5-14.
//  Copyright (c) 2014年 Ai. All rights reserved.
//

#import "AiUserManager.h"
#import "AiDataRequestManager.h"
#import "UMOpenUDID.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AiUserManager

+ (AiUserManager *)shareInstance {
    static AiUserManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.openUdid = [UMOpenUDID value];
        self.babyId = -1;

    }
    return self;
}


-(void)userRegistWithCompletion:(void (^)(RegisterResp *result , NSError * error))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^{
        @try {
            NSLog(@"userRegistWithReq here!");
            ReqHead * reqHead = [[ReqHead alloc] initWithBabyId:-1 guid:self.openUdid version:VERSION];
            RegisterResp *registResp = [[AiThriftManager shareInstance].userClient userRegister:reqHead];
            if (registResp.resCode == ResponseCodeSuccess) {
                self.passwd = registResp.pwd;
                self.babyId = registResp.babyId;
                [[NSUserDefaults standardUserDefaults] setValue:self.passwd forKey:@"passwd"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.babyId] forKey:@"babyId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                completion(registResp,nil);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:@"server error" code:registResp.resCode userInfo:nil];
                completion(nil,error);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"regist error!!");
        }
    }];
}

-(void)loginWithCompletion:(void (^)(int result))completion{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"passwd"]) {
        self.passwd = [[NSUserDefaults standardUserDefaults] valueForKey:@"passwd"];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"babyId"]) {
            self.babyId = [[[NSUserDefaults standardUserDefaults] valueForKey:@"babyId"] intValue];
        }
        [self userLogin:^(int result) {
            if (completion) {
                completion(result);
            };
        }];
    } else {
        NSLog(@"loginWithCompletion here!!");
        NSString *openUdid = self.openUdid;
        [self userRegistWithCompletion:^(RegisterResp *result, NSError *error) {
            [self userLogin:^(int result) {
                if (completion) {
                    completion(result);
                };
            }];
        }];
    }
}

-(void)userLogin:(void (^)(int result))completion
{
    [[AiThriftManager shareInstance].queue addOperationWithBlock:^{
        @try {
            NSLog(@"userLogin here!!");
            ReqHead *reqHead = [[ReqHead alloc] initWithBabyId:self.babyId guid:self.openUdid version:VERSION];
            NSString * seedString = [[AiThriftManager shareInstance].userClient getAuthSeed:reqHead];
            NSString * authString = [NSString stringWithFormat:@"%d%@%@%@",self.babyId,self.openUdid,self.passwd,seedString];
            NSLog(@"authString is %@ %d openUdid is %@ seedString is %@",authString,self.babyId,self.openUdid,seedString);
            
            NSString * authMd5String = [AiUserManager md5Value:authString];
            
            LoginReq *loginReq = [[LoginReq alloc] initWithHead:reqHead authStr:authMd5String];
            
            int reslut = [[AiThriftManager shareInstance].userClient login:loginReq];
            if (completion) {
                completion(reslut);
            }
            
            NSLog(@"result is %d ----------- %d",reslut,loginReq.authStr.length);
        }
        @catch (NSException *exception) {
            NSLog(@"login error!!");
        }
    }];
}

+ (NSString *)md5Value:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    printf("cStr is %s",cStr);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end