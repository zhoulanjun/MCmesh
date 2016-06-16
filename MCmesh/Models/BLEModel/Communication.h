//
//  Communication.h
//  Familie
//
//  Created by tom on 15/8/24.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Communication : NSObject

@property (nonatomic, assign) NSInteger resultCode;
@property (nonatomic, strong) NSString *resultMsg;
@property (nonatomic, assign) BOOL success;

@end
