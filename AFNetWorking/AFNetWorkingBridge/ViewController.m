//
//  ViewController.m
//  AFNetWorkingBridge
//
//  Created by NetEase on 16/2/4.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "ViewController.h"
#import "RDDownloadFontListTask.h"

@interface ViewController ()<RDRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //两种方法
    //第一种Delegate方法
    RDDownloadFontListTask *api = [[RDDownloadFontListTask alloc] init];
//    api.delegate = self;
//    [api start];
    //第二种Block方法
    if ([api cacheJson]) {
        NSDictionary *json = [api cacheJson];
        NSLog(@"json = %@", json);
        // show cached data
    }
    [api startWithCompletionBlockWithSuccess:^(RDBaseRequest *request) {
        NSLog(@"update ui");
        NSData *data = [request responseData];
        //get allfonts,解析it
        
    } failure:^(RDBaseRequest *request) {
        NSLog(@"failed");
    }];
}

- (void)requestFinished:(RDBaseRequest *)request
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
