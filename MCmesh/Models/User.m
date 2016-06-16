//
//  User.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "User.h"

@implementation User

single_implementation(User)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceArr=[NSMutableArray array];
    }
    return self;
}

@end
