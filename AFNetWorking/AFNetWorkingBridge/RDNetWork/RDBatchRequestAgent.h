//
//  RDBatchRequestAgent.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDBatchRequest.h"

@interface RDBatchRequestAgent : NSObject
+ (RDBatchRequestAgent *)sharedInstance;

- (void)addBatchRequest:(RDBatchRequest *)request;

- (void)removeBatchRequest:(RDBatchRequest *)request;
@end
