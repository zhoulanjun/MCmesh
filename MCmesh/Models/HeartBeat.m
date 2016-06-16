//
//  HeartBeat.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "HeartBeat.h"
#import "HttpTools.h"

static HeartBeat *shareInstance = nil;

@implementation HeartBeat
single_implementation(HeartBeat)


+ (HeartBeat *)sharedInstance
{
    @synchronized(self)
    {
        if (shareInstance == nil) {
            shareInstance = [[HeartBeat alloc]init];
        }
    }
    
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //登出后 暂停心跳计时器
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(heartBeatTimeInvalidate) name:@"plsInvalidateHeratBeateTime" object:nil];
//        _isHeartBeatSuc = NO;
    }
    return self;
}



-(void)regularlySend
{
    [self performSelectorInBackground:@selector(multiThread) withObject:nil];
    
}
-(void)multiThread
{
    if (_timer && [_timer isValid])
    {
        return;
    }
    [self heartRepeatBeat];
    
    _timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}



-(void)timerAction
{
    [self heartRepeatBeat];
    
}

-(void)heartRepeatBeat
{
    //Step1:登陆成功，向云端发送心跳    
    [HttpTools heartBeat];
}



@end
