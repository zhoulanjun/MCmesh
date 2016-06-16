//
//  Interface.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/12.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Interface : NSObject

+(void)requestWithRequestID:(REQUEST_ID)requestID
                    withUrl:(NSString *) urlString
                 httpMethod: (NSString *) httpMethods
                   withData: (NSData *) xmlData
            blockCompletion: (void(^)(NSData *data))finishBlock
                  withError:(void(^)(NSError *error))errorBlock;

@end
