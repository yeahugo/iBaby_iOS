//
//  JGThriftManager.h
//  FourPlayer
//
//  Created by yeahugo on 14-3-15.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AiDefine.h"

#import "TSocketClient.h"
#import "TBinaryProtocol.h"
#import "TFramedTransport.h"
#import "TMultiplexedProtocol.h"

#import "shy_client_server.h"

@interface AiThriftManager : NSObject

@property (nonatomic, strong) ResourceManagerClient * resourceClient;

@property (nonatomic, strong) RecommendManagerClient * recommendClient;

@property (nonatomic, strong) UserManagerClient *userClient;

+ (AiThriftManager *)shareInstance;

-(void)reConnect;
@end
