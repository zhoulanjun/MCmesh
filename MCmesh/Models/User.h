//
//  User.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface User : NSObject
single_interface(User)

@property (nonatomic,retain)NSString  *userName;
@property (nonatomic,retain)NSString  *password;
@property (nonatomic,retain)NSString  *userId;
@property (nonatomic,retain)NSString  *random;

//用户名下拥有的设备
@property (nonatomic,retain)NSMutableArray *deviceArr;


/**
 * 蓝牙连接周边次数
 */
@property (nonatomic,assign) NSInteger  connectTime;
/**
 * 用户准备关联的设备是否被关联的标记ownedByOther
 */
@property (nonatomic,strong) NSString  *addDeviceOrSetWifi;

/**
 * 判断时认为断开还是系统断开蓝牙连接
 */
@property (nonatomic,strong) NSString  *disconnectByWho;


//当前Mesh网络的NetIv 和 NetKey
@property (nonatomic,retain) NSString *netIv;
@property (nonatomic,retain) NSData   *netIVData;

@property (nonatomic,retain) NSString *netKey;
@property (nonatomic,retain) NSData   *netKeyData;


/*
用来标记所扫描的周边设别类型
0x0001:Gateway Node
0x0002:Socket Node
0x0003:Sensor Node
0x0004:Keypad Node
 */
@property (nonatomic,retain)NSData * nodeTypeData;





/**
 * APP用户使用的网络类型 WIFI or 运营商网络
 */
@property (nonatomic,retain)NSString *useNetType;


@end
