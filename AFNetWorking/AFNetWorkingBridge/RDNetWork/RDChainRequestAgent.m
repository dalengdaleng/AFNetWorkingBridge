//
//  RDChainRequestAgent.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "RDChainRequestAgent.h"

@interface RDChainRequestAgent()

@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation RDChainRequestAgent
+ (RDChainRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addChainRequest:(RDChainRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeChainRequest:(RDChainRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end
