//
//  HttpTools.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/12.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "HttpTools.h"
#import "Interface.h"
#import "IpcModel.h"

#import "XMLReader.h"
#import "XMLWriter.h"
#import "AESCrypt.h"
#import <CommonCrypto/CommonDigest.h>

#import "getDevInfoByBLE.h"


@implementation HttpTools

#pragma mark - 登录
+(void)logIn:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOT_URL, SIGNURL];

    NSData *RequestData=[self getSigninXML];

    
    [Interface requestWithRequestID:SIGN_IN withUrl:url httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
        
        NSError *err;
        NSDictionary *dataDic=[XMLReader dictionaryForXMLData:data error:&err];
        NSString *statusCode = dataDic[@"appUserLogin"][@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString = dataDic[@"appUserLogin"][@"ResponseStatus"][@"statusString"][@"text"];
        
        [User sharedUser].userId=dataDic[@"appUserLogin"][@"userId"][@"text"];
        [User sharedUser].random=dataDic[@"appUserLogin"][@"random"][@"text"];

        
        
        if (block)
        {
            if ([statusCode isEqualToString:@"0"]&&[statusString isEqualToString:@"0"]) {
                block(YES);
            }else
            {
                block(NO);
            }
        }
    } withError:^(NSError *error) {
        if (block) {
            block(NO);
        }
    }];
}

#pragma mark -登录时传过去的data
+(NSData *)getSigninXML
{
    User *user=[User sharedUser];
    NSString * randomStr = [self getRandomStr:8 for:@"Signin"];
    NSString * encodeStr = [self md5String:user.password];
    NSDictionary *dic = @{@"appUserLogin":@{@"email":user.userName,@"clientKind":FAMILIE,@"passWord":encodeStr,@"random":randomStr}};
    NSData *xmldata=[[XMLWriter XMLStringFromDictionary:dic] dataUsingEncoding:NSUTF8StringEncoding];
    return xmldata;
}

#pragma mark -随机生成字符串
+(NSString *)getRandomStr:(int )CharNum  for:(NSString *)ivOrKeyOrsignin
{
    User *user=[User sharedUser];
//    CharNum==8  CharNum==16
    int NUMBER_OF_CHARS = CharNum;
    char data[NUMBER_OF_CHARS];
//    赋值给user的netIVData netKeyData
    unsigned char cmd[NUMBER_OF_CHARS];
    
    for (int x=0;x<NUMBER_OF_CHARS;
         data[x++] = (char)('A' + (arc4random_uniform(26))));
    NSString *dataPoint = @"";
    for (int i = 0; i < NUMBER_OF_CHARS; i ++)
    {
        NSString *newStr = [NSString stringWithFormat:@"%x",data[i]&0xff];
        cmd[i]=data[i]&0xff;
        NSLog(@"cmd[%d]=====%d",i,data[i]&0xff);
        
        if ([newStr length] == 1)
        {
            dataPoint = [NSString stringWithFormat:@"%@0%@",dataPoint,newStr];
        }else{
            dataPoint = [NSString stringWithFormat:@"%@%@",dataPoint,newStr];
        }
        NSLog(@"%@",dataPoint);
    }
    if ([ivOrKeyOrsignin isEqualToString:@"netIv"])
    {
        NSLog(@"%@",[NSData dataWithBytes:cmd length:NUMBER_OF_CHARS]);
        NSData *randomIVData=[NSData dataWithBytes:cmd length:NUMBER_OF_CHARS];
        
       user.netIVData = randomIVData;
        
    }else if ([ivOrKeyOrsignin isEqualToString:@"netKey"])
    {
        NSData *randomKEYData=[NSData dataWithBytes:cmd length:NUMBER_OF_CHARS];
        user.netKeyData = randomKEYData;
    }
    
    NSLog(@"%@----%ld",dataPoint,dataPoint.length);
    return dataPoint;
}

#pragma mark -MD5加密
+(NSString *) md5String:(NSString *) str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
    
}
#pragma mark - 做心跳
+(void)heartBeat
{
    NSString *url = [NSString stringWithFormat:@"%@%@",ROOT_URL,HEART_BEAT_URL];
    
    User *user=[User sharedUser];
    NSData *heartData=[[XMLWriter XMLStringFromDictionary:@{@"appHeartBeat":@{@"userId":user.userId,@"random":user.random}}] dataUsingEncoding:NSUTF8StringEncoding];
    
    [Interface requestWithRequestID:HEART_BEAT withUrl:url httpMethod:@"POST" withData:heartData blockCompletion:^(NSData *data) {
        
        
        
    } withError:^(NSError *error) {
        
    }];
}



#pragma mark - 获取所有设备列表
+(void)getAllIPCCameras:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOT_URL, HTTP_GET_ALL_MEMBER_INFO_URL];
    
    [Interface requestWithRequestID:ALL_MEMBER_INFO withUrl:url httpMethod:@"GET" withData:nil blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        
        id element=dic[@"appQueryRelatedDevices"][@"ownDevices"][@"devices"];
//        赋值
        if (block)
        {
            
            [[User sharedUser].deviceArr removeAllObjects];

            block([IpcModel analysisDevicesFrom:element]);
        }
//        解析出数据放到数组中去
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
    }];
}


#pragma mark - 创建MESH网络
+(void)createMeshNetFor:(NSInteger)locIndex WithSN:(NSString *)sn WithName:(NSString *)name block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", ROOT_URL,APPDEVICE,CREATEMESH];
    NSData *RequestData=[self getCreateMeshNetFor:locIndex DataSN:sn Name:name];
    
    
    [Interface requestWithRequestID:CREATE_MESH withUrl:url httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        
        NSString *statusCode=dic[@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"ResponseStatus"][@"statusString"][@"text"];

#warning statusCode statusString
        
        if (block)
        {
            block(YES);
        }
        
        
        //        解析出数据放到数组中去
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
    }];
}
#pragma mark -创建MESH网络时传过去的data
+(NSData *)getCreateMeshNetFor:(NSInteger)locIndex DataSN:(NSString *)sn Name:(NSString *)name
{
    IpcModel *iModel=[User sharedUser].deviceArr[locIndex];
    
    //读取plist文件的内容
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:FILEPATH];
    NSLog(@"---plist一创建MESH网络时读到的plist文件---%@",dataDictionary);
    
//    NSString *netIv=[self getNetIv];
    iModel.netIv=dataDictionary[sn][@"netIv"];

//    NSString *netKey=[self getNetkey];
    iModel.netKey=dataDictionary[sn][@"netKey"];

    NSDictionary *dic = @{@"appCreateMesh":@{@"SN":sn,@"netIv":iModel.netIv,@"netKey":iModel.netKey,@"netName":name}};
    NSData *xmldata=[[XMLWriter XMLStringFromDictionary:dic] dataUsingEncoding:NSUTF8StringEncoding];
    return xmldata;
}

#pragma mark - 删除MESH网络
+(void)deleteMeshNetWithSn:(NSString *)sn   block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", ROOT_URL,APPDEVICE,sn,DELETEMESH];

    [Interface requestWithRequestID:DELETE_MESH withUrl:url httpMethod:@"DELETE" withData:nil blockCompletion:^(NSData *data) {
        
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        
        NSString *statusCode=dic[@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"ResponseStatus"][@"statusString"][@"text"];
        
#warning statusCode statusString
        
        if (block)
        {
            block(YES);
        }
        

        
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
        
    }];

}
#pragma mark - 解除关联该设备IPC
+(void)unlinkDeviceWithSn:(NSString *)snString  block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@/%@", ROOT_URL,UNLINKDEVICE,snString];
    [Interface requestWithRequestID:UNLINKDEV withUrl:url httpMethod:@"GET" withData:nil blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        NSLog(@"解除关联该设备IPC 返回的信息%@",dic);
        NSString *statusCode=dic[@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"ResponseStatus"][@"statusString"][@"text"];
        
        if ([statusCode isEqualToString:@"0"] && [statusString isEqualToString:@"0"])
        {
            block(YES);
        }
        
    } withError:^(NSError *error) {
        
        block(NO);
        
        
    }];
    
    
    

}



#pragma mark - 请求获取Mesh信息
+(void)requestMeshInfoWithSn:(NSString *)sn block:(CommonDicBlock)block errorIn:(ErrorInfo)errorInfo
{

    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", ROOT_URL,APPDEVICE,sn,REQMESHINFO];
    
    [Interface requestWithRequestID:DELETE_MESH withUrl:url httpMethod:@"GET" withData:nil blockCompletion:^(NSData *data) {
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        
        NSLog(@"2.3	APP用户请求获取Mesh信息 返回信息%@",dic);
#warning MeshInfo 建立一个模型
        
        if (block)
        {
            block(dic);
        }
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
        
    }];
}

#pragma mark - 请求获取mesh状态信息
+(void)requestMeshStatusInfoWithSn:(NSString *)sn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", ROOT_URL,APPDEVICE,sn,REQMESHSTATUSINFO];
    
    [Interface requestWithRequestID:DELETE_MESH withUrl:url httpMethod:@"GET" withData:nil blockCompletion:^(NSData *data) {
        
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        
        NSLog(@"2.4	APP用户请求获取mesh状态信息 返回信息%@",dic);
#warning MeshInfo 建立一个模型
        
        //        if (block)
        //        {
        //            block(YES);
        //        }
        //
        
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
    }];
}

#pragma mark - 建立节点组
+(void)createNodeGroupWithSn:(NSString *)sn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", ROOT_URL,APPDEVICE,CREATENODE];
    NSData *RequestData=[self getCreateNodeGroupDataWithSn:(NSString *)sn];
    
    
    [Interface requestWithRequestID:CREATE_MESH withUrl:url httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
         NSLog(@"2.5	APP用户建立节点组 返回信息%@",dic);
        NSString *statusCode=dic[@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"ResponseStatus"][@"statusString"][@"text"];
        
#warning statusCode statusString
        
        if (block)
        {
            block(YES);
        }
        
        //        解析出数据放到数组中去
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
        
    }];
    
}
+(NSData *)getCreateNodeGroupDataWithSn:(NSString *)sn
{
    NSDictionary *nodeListDic=@{};
    NSDictionary *dic = @{@"appMeshGroup":@{@"SN":sn,@"groupId":@"001",@"groupName":@"livingroom lights",@"nodeInfoList":nodeListDic}};
    NSData *xmldata=[[XMLWriter XMLStringFromDictionary:dic] dataUsingEncoding:NSUTF8StringEncoding];
    return xmldata;
}

#pragma mark - 增加mesh节点
+(void)addMeshNode:(NSString *)nodename ForIndex:(NSInteger)locIndex  WithSn:(NSString *)sn  block:(CommonDicBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@", ROOT_URL,APPDEVICE,ADDMESHNODE];
    NSData *RequestData=[self addNode:nodename ForIndex:locIndex Sn:sn];
    
    [Interface requestWithRequestID:CREATE_MESH withUrl:url httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        
        if (block)
        {
            block(dic);
        }
        //        解析出数据放到数组中去
    } withError:^(NSError *error) {
        
        if (errorInfo)
        {
            errorInfo(error);
        }
    }];
}

+(NSData *)addNode:(NSString *)nodename ForIndex:(NSInteger)locIndex Sn:(NSString *)sn
{
   User *user = [User sharedUser];
   IpcModel *model=user.deviceArr[locIndex];
    
    getDevInfoByBLE *getInfo = [getDevInfoByBLE shareInstanc];

     NSDictionary *attrDic = [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"version", @"urn:skylight", @"xmlns", nil];
    
//    NSDictionary *dic = @{@"appAddNode":@{@"SN":sn,@"netIv":model.netIv,@"netKey":model.netKey,@"nodeSn":getInfo.nodeSn,@"nodeType":getInfo.nodeType,@"nodeName":nodename,@"nodeId":@"198",@"nodeMac":getInfo.nodeMac}};
    
    //读取plist文件的内容
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:FILEPATH];
    NSLog(@"--添加节点到Mesh网络----%@",dataDictionary);
    
    NSDictionary *dic = @{@"appAddNode":@{@"SN":sn,@"nodeSn":getInfo.nodeSn,@"nodeType":@"2",@"nodeName":nodename,@"nodeId":dataDictionary[sn][getInfo.nodeSn],@"nodeMac":getInfo.nodeMac,XmlAttributeKey:attrDic}};
    
    NSData *xmldata=[[XMLWriter XMLStringFromDictionary:dic] dataUsingEncoding:NSUTF8StringEncoding];
    return xmldata;
}

#pragma mark - 删除mesh节点
+(void)deleteMeshNodeIpcSn:(NSString *)ipcSn  nodeSn:(NSString *)nodeSn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    
}

#pragma mark - 对节点操作
+(void)operateToThisNodeIPCSn:(NSString *)ipcSn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOT_URL,OPERATENODE];
    NSData *RequestData=[self operateNodeData:ipcSn];
    [Interface requestWithRequestID:OPERNODE withUrl:url
                         httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
                             
                             
                         } withError:^(NSError *error) {
                             
                             
                         }];
}



+(NSData *)operateNodeData:(NSString *)ipcSn
{
//    <groupId>XXX</groupId>  //一次操作对应一个gropId或nodeId，两个参数只能带一个
//    <nodeId>XXX</ nodeId>  //一次操作对应一个gropId或nodeId，两个参数只能带一个
    NSDictionary *dic=@{@"meshOperate":@{@"SN":ipcSn,@"nodeId":@"1",@"action":@"open"}};
    NSLog(@"%@",dic);
    
    NSString *xmlString=[XMLWriter  XMLStringFromDictionary:dic];
    NSData *xmlData=[xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"这里%@",xmlData);
    
    return xmlData;

}

#pragma mark - IPC注册
+(void)IPCRegblock:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo

{
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOT_URL,IPCREGISTER];
    NSData *RequestData=[self IPCRegisterXML];
    
        [Interface requestWithRequestID:IPCREG withUrl:url httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
            
            NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
            NSLog(@"IPC注册，验证SN有效性 返回信息%@",dic);
            NSString *statusCode=dic[@"ResponseStatus"][@"statusCode"][@"text"];
            NSString *statusString=dic[@"ResponseStatus"][@"statusString"][@"text"];
            
#warning statusCode statusString
            if (block)
            {
                if ([statusCode isEqualToString:@"0"]&&[statusString isEqualToString:@"0"]) {
                    block(YES);
                }else
                {
                    block(NO);
                }
            }


            
            
        } withError:^(NSError *error) {
            
            
            
        }];
}


#pragma mark-IPC注册请求的data
+(NSData *)IPCRegisterXML
{
    NSString *timeZoneStr=[self GetTimeZoneStr];
    getDevInfoByBLE *getInfo=[getDevInfoByBLE shareInstanc];
    NSString *dateStr=[self BLEGetTimeToStandardTime:getInfo.bleGetEncryptKey];

        NSDictionary *dic=@{@"appDeviceRegist":@{@"timeZone":timeZoneStr,@"SN":getInfo.bleGetSN,@"sessionInfo":getInfo.bleGetEncryptInfo,@"dateTime":dateStr}};
        NSLog(@"%@",dic);

    NSString *xmlString=[XMLWriter  XMLStringFromDictionary:dic];
    NSData *xmlData=[xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"这里%@",xmlData);
    
    return xmlData;
}

#pragma mark-获取当前时间New-ISO8061时间
+(NSString *)GetNewISOdateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSZ"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableString *str=[[NSMutableString alloc]initWithString:dateString];
    //    [str insertString:@":" atIndex:26];
    NSString *subStr=[str substringToIndex:19];
    
    return subStr;
}

//时区为+08：00
+(NSString *)GetTimeZoneStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableString *str=[[NSMutableString alloc]initWithString:dateString];
    NSLog(@"%@",dateString);
    [str insertString:@":" atIndex:22];
    NSLog(@"%@",str);
    
    NSRange range1=[str rangeOfString:@"+"];
    NSString *timeZoneStr = [str substringFromIndex:range1.location];
    NSLog(@"%@",timeZoneStr);
    
    return timeZoneStr;
}

+(NSString *)BLEGetTimeToStandardTime:(NSString *)BLEGetTimeStr
{
    
    NSLog(@"%@",BLEGetTimeStr);
    NSString *strYear=[BLEGetTimeStr substringWithRange:NSMakeRange(2, 4)];
    NSLog(@"%@",strYear);
    
    NSString *strMonth=[BLEGetTimeStr substringWithRange:NSMakeRange(6, 2)];
    NSLog(@"%@",strMonth);
    
    NSString *strDay=[BLEGetTimeStr substringWithRange:NSMakeRange(8, 2)];
    
    NSString *strHour=[BLEGetTimeStr substringWithRange:NSMakeRange(10, 2)];
    NSString *strMin=[BLEGetTimeStr substringWithRange:NSMakeRange(12, 2)];
    NSString *strSec=[BLEGetTimeStr substringWithRange:NSMakeRange(14, 2)];
    NSString *endStr=[NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",strYear,strMonth,strDay,strHour,strMin,strSec];
    NSLog(@"%@",endStr);
    
    
    return endStr;
}

#pragma mark - 查询设备是否连上云端
+(void)IPCConnectCloudSn:(NSString *)sn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
     NSString *url = [NSString stringWithFormat:@"%@%@%@%@", ROOT_URL,APPDEVICE,sn,ISLIVEDEVICE];
    
    [Interface requestWithRequestID:ISLIVEDEV withUrl:url httpMethod:@"GET" withData:nil blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        NSLog(@"查询IPC设备是否在线 返回信息%@",dic);
        NSString *statusCode=dic[@"isLiveDevice"][@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"isLiveDevice"][@"ResponseStatus"][@"statusString"][@"text"];
        
        if (block)
        {
            if ([statusCode isEqualToString:@"0"]&&[statusString isEqualToString:@"0"]) {
                block(YES);
            }else
            {
                block(NO);
            }
        }

        
        
        
        
    } withError:^(NSError *error) {
        
    }];
    

}

#pragma mark - 查询是否被关联
+(void)orNotTobeLinkedSn:(NSString *)sn block:(CommonDicBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", ROOT_URL,APPDEVICE,sn,OWNEDBYOTHER];
    
    [Interface requestWithRequestID:ISLIVEDEV withUrl:url httpMethod:@"GET" withData:nil blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        NSLog(@"查询设备是否被其他人关联 返回信息%@",dic);
        if (block)
        {
            block(dic);
        }
    } withError:^(NSError *error) {
    }];
}


#pragma mark - 请求关联设备
+(void)requestToRelateblock:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOT_URL,DEVICELINK];

    
    NSData *RequestData=[self DeviceLinkXML];
    
    [Interface requestWithRequestID:IPCREG withUrl:url httpMethod:@"POST" withData:RequestData blockCompletion:^(NSData *data) {
        
        NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];
        NSLog(@"请求关联设备 返回信息%@",dic);
        NSString *statusCode=dic[@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"ResponseStatus"][@"statusString"][@"text"];
        
#warning statusCode statusString
        
        if (block)
        {
            if ([statusCode isEqualToString:@"0"]&&[statusString isEqualToString:@"0"]) {
                block(YES);
            }else
            {
                block(NO);
            }
        }

        
    } withError:^(NSError *error) {
        
        
        
    }];


}


#pragma mark-设备关联
+(NSData *)DeviceLinkXML
{
    getDevInfoByBLE *getInfo=[getDevInfoByBLE shareInstanc];
    
    //48B1517B142C9
    if (getInfo.bleGetTypeNo == nil)
    {
        //如果没有选择设备类型 那么默认是@"0" Familie Use
        getInfo.bleGetTypeNo = @"0";
    }
    NSLog(@"%@",getInfo.bleGetTypeNo);

     getInfo.bleGetTypeName=@"DIY ";
    
    NSDictionary *dic =@{@"appDeviceLink":@{@"SN":getInfo.bleGetSN,@"deviceKind":getInfo.bleGetTypeNo,@"deviceName":getInfo.bleGetTypeName}};
    NSLog(@"%@",dic);
    
    
    
    NSString *xmlString=[XMLWriter  XMLStringFromDictionary:dic];
    NSData *xmlData=[xmlString dataUsingEncoding:NSUTF8StringEncoding];
    return xmlData;

}





@end
