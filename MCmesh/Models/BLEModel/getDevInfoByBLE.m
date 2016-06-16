//
//  getDevInfoByBLE.m
//  Familie
//
//  Created by zhoulanjun on 15/7/22.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import "getDevInfoByBLE.h"

@implementation getDevInfoByBLE
+(getDevInfoByBLE *)shareInstanc
{
    static getDevInfoByBLE *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}
@end
