//
//  RDChainRequestAgent.h
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDChainRequest.h"

@interface RDChainRequestAgent : NSObject
+ (RDChainRequestAgent *)sharedInstance;

- (void)addChainRequest:(RDChainRequest *)request;

- (void)removeChainRequest:(RDChainRequest *)request;
@end
