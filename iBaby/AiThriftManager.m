//
//  JGThriftManager.m
//  FourPlayer
//
//  Created by yeahugo on 14-3-15.
//  Copyright (c) 2014年 AiJingang. All rights reserved.
//

#import "AiThriftManager.h"

@implementation AiThriftManager

+ (AiThriftManager *)shareInstance {
    static AiThriftManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

-(id)init
{
    if (self = [super init]) {
//        NSString *hostString = @"172.16.62.144";
//        int port = HOST_PORT;    //9089
        [self reConnect];
        
//        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        self.queue = queue;
    }
    return self;
}

-(void)reConnect
{
    TSocketClient *transport = [[TSocketClient alloc] initWithHostname:AI_HOST_IP port:AI_HOST_PORT];
    TFramedTransport *frameTransport = [[TFramedTransport alloc] initWithTransport:transport];
    TBinaryProtocol *protocol = [[TBinaryProtocol alloc] initWithTransport:frameTransport strictRead:YES strictWrite:YES];
    TMultiplexedProtocol *resourceManagerProtocol = [[TMultiplexedProtocol alloc] initWithProtocol:protocol serviceName:@"ResourceManagerProcessor"];
    ResourceManagerClient * resourceClient = [[ResourceManagerClient alloc] initWithProtocol:resourceManagerProtocol];
    self.resourceClient = resourceClient;

    TMultiplexedProtocol *userManagerProtocol = [[TMultiplexedProtocol alloc] initWithProtocol:protocol serviceName:@"UserManagerProcessor"];
    self.userClient = [[UserManagerClient alloc] initWithProtocol:userManagerProtocol];
    
    TMultiplexedProtocol *reportManagerProtocol = [[TMultiplexedProtocol alloc] initWithProtocol:protocol serviceName:@"ReportManagerProcessor"];
    self.reportClient = [[ReportManagerClient alloc] initWithProtocol:reportManagerProtocol];

}
@end
