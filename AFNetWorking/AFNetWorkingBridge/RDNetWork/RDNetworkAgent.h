//
//  RDNetworkAgent.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBaseRequest.h"
#import "AFNetworking.h"

@interface RDNetworkAgent : NSObject
+ (RDNetworkAgent *)sharedInstance;

- (void)addRequest:(RDBaseRequest *)request;

- (void)cancelRequest:(RDBaseRequest *)request;

- (void)cancelAllRequests;

// 根据request和networkConfig构建url
- (NSString *)buildRequestUrl:(RDBaseRequest *)request;
@end
