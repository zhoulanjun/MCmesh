//
//  IpcModel.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "IpcModel.h"

@implementation IpcModel
+(BOOL)analysisDevicesFrom:(id)element
{

    if ([element isKindOfClass:[NSDictionary class]])
    {
        IpcModel *ipcMd=[[IpcModel alloc]init];
        ipcMd.SN = element[@"SN"][@"text"];
        ipcMd.deviceKind=element[@"deviceKind"][@"text"];
        ipcMd.deviceModel=element[@"deviceModel"][@"text"];
        ipcMd.deviceName=element[@"deviceName"][@"text"];
        ipcMd.deviceId=element[@"deviceId"][@"text"];
        ipcMd.onLineStatus=element[@"onLineStatus"][@"text"];
        
        ipcMd.humidity=element[@"Sensors"][@"humidity"][@"text"];
        ipcMd.temperature=element[@"Sensors"][@"temperature"][@"text"];
        [[User sharedUser].deviceArr addObject:ipcMd];

    }else if ([element isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *singleDic in element)
        {
            IpcModel *ipcMd=[[IpcModel alloc]init];
            ipcMd.SN = singleDic[@"SN"][@"text"];
            ipcMd.deviceKind=singleDic[@"deviceKind"][@"text"];
            ipcMd.deviceModel=singleDic[@"deviceModel"][@"text"];
            ipcMd.deviceName=singleDic[@"deviceName"][@"text"];
            ipcMd.deviceId=singleDic[@"deviceId"][@"text"];
            ipcMd.onLineStatus=singleDic[@"onLineStatus"][@"text"];
            
            ipcMd.humidity=singleDic[@"Sensors"][@"humidity"][@"text"];
            ipcMd.temperature=singleDic[@"Sensors"][@"temperature"][@"text"];
            [[User sharedUser].deviceArr addObject:ipcMd];
        
        }
    
    }
    return YES;
}

@end
