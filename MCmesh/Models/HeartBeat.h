//
//  HeartBeat.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeartBeat : NSObject
@property (nonatomic, strong)NSTimer *timer;
single_interface(HeartBeat)

-(void)regularlySend;
@end
