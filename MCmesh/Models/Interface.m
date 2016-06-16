//
//  Interface.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/12.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "Interface.h"
#import "MKNetworkKit.h"
#import "XMLWriter.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Interface
+(void)requestWithRequestID:(REQUEST_ID)requestID
                    withUrl:(NSString *) urlString
                 httpMethod: (NSString *) httpMethods
                   withData: (NSData *) xmlData
            blockCompletion: (void(^)(NSData *data))finishBlock
                  withError:(void(^)(NSError *error))errorBlock
{
    MKNetworkEngine * engine = [[MKNetworkEngine alloc] init];
    
    MKNetworkOperation * operation = [engine operationWithURLString:urlString params:nil httpMethod:httpMethods];
    

    NSString *digestUrl=nil;
    
    if (requestID != SIGN_IN)
    {
        digestUrl=[urlString substringFromIndex:ROOT_URL.length];
    }
  
    if (digestUrl)
    {
        NSDictionary *sendDic=[self getDic:nil withMethod:httpMethods withUrl:digestUrl];
        [operation addHeaders:sendDic];
    }
    
    
    if (xmlData != nil)
    {
        operation.postDataEncoding = MKNKPostDataEncodingTypeCustom;
        [operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
                
                NSLog(@"======发送的XML字串===为=====\n%@",[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding]);
                return [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
                
            } forType:@"application/xml"];
    }
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         if (finishBlock)
         {
             finishBlock(completedOperation.responseData);
         }
         NSString *xmlString=[[NSString alloc]initWithData:completedOperation.responseData encoding:NSUTF8StringEncoding];
         NSLog(@"返回的xmlString为：%@",xmlString);
     } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (errorBlock) {
             errorBlock(error);
         }
     }];
    [engine enqueueOperation:operation];
}



#pragma mark -心跳


+(NSDictionary *)getDic:(NSString *)errorStr withMethod:(NSString *)method  withUrl:(NSString *)url
{
    User *user=[User sharedUser];
    
        NSLog(@"%@",url);
    if (![url containsString:@"/sklcloud"])
    {
        url=[@"/sklcloud" stringByAppendingString:url];
    }
    
    NSString *response = [self getResponseStrWithErrorStr:errorStr withMethod:method withUrl:url];
    NSString *authorization=[NSString stringWithFormat:@"Digest userId=%@,nonce=\"%@\",response=\"%@\",uri=\"%@\"",user.userId,user.random,response,url];
    return @{@"Authorization":authorization};
    
}

#pragma mark -发送心跳的response
+(NSString *)getResponseStrWithErrorStr:(NSString *)errorStr withMethod:(NSString *)method withUrl:(NSString *)url
{
    User *u=[User sharedUser];
    
    NSString *psdAfterMd5=[self md5String:u.password];
    
    
    NSString *ha1Str=[NSString stringWithFormat:@"%@:%@:%@",u.userId,u.random,psdAfterMd5];
    NSString *ha2Str=[NSString stringWithFormat:@"%@:%@",method,url];
    
    NSString *ha1StrAfterMd5=[self md5String:ha1Str];
    NSString *ha2StrAfterMd5=[self md5String:ha2Str];
    
    NSString *responseStr=[NSString stringWithFormat:@"%@:%@:%@",ha1StrAfterMd5,u.random,ha2StrAfterMd5];
    
    NSString *responseAfterMd5=[self md5String:responseStr];
    
    //    NSLog(@"====ha1==%@  加密 %@",ha1Str,ha1StrAfterMd5);
    //    NSLog(@"====ha2==%@  加密 %@",ha2Str,ha2StrAfterMd5);
    //    NSLog(@"====ha3==%@  加密 %@",responseStr,responseAfterMd5);
    
    return responseAfterMd5;
    
}

+(NSString *) md5String:(NSString *) str
{
    if (!str || str.length == 0) {
        return nil;
    }
    
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
    
}


@end
