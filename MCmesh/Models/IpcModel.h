//
//  IpcModel.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IpcModel : NSObject

@property (nonatomic,retain)NSString *SN;
@property (nonatomic,retain)NSString *deviceKind;
@property (nonatomic,retain)NSString *deviceModel;
@property (nonatomic,retain)NSString *deviceName;
@property (nonatomic,retain)NSString *deviceId;
@property (nonatomic,retain)NSString *onLineStatus;
@property (nonatomic,retain)NSString *humidity;
@property (nonatomic,retain)NSString *temperature;


//当前Mesh网络的NetIv 和 NetKey
@property (nonatomic,retain) NSString *netIv;
@property (nonatomic,retain) NSString *netKey;
@property (nonatomic,retain) NSString *netName;


+(BOOL)analysisDevicesFrom:(id)element;

@end
