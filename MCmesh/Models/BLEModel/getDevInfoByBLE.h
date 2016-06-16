//
//  getDevInfoByBLE.h
//  Familie
//
//  Created by zhoulanjun on 15/7/22.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getDevInfoByBLE : NSObject

/**
 *  IPC类设备的唯一标识
 */
@property (nonatomic,copy) NSString *bleGetSN;
/**
 *  产品编码
 */
@property (nonatomic,copy) NSString *bleGetProductCode;
/**
 *  生产日期
 */
@property (nonatomic,copy) NSString *bleGetProduceTime;
/**
 *  生产日期
 */
@property (nonatomic,copy) NSString *bleGetVersionNum;
/**
 *  密钥
 */
@property (nonatomic,copy) NSString *bleGetEncryptKey;
/**
 *  从蓝牙获取的加密后的数据
 */
@property (nonatomic,copy) NSString *bleGetEncryptInfo;
/**
 *  返回的tokenStr
 */
@property (nonatomic,copy) NSString *bleGetTokenStr;

/**
 *  设备名
 */
@property (nonatomic,copy) NSString *bleGetTypeName;

/**
 *  根据打钩选择的种类
 */
@property (nonatomic,copy) NSString *bleGetTypeNo;

/**
 *  已经连接上某个周边设备
 */
@property (nonatomic,assign) BOOL _snIsLegal;




/**
 *  Node 节点的Mac
 */
@property (nonatomic,copy) NSString *nodeMac;
/**
 *  Node 节点的Type
 */
@property (nonatomic,copy) NSString *nodeType;
/**
 *  Node 节点的Sn
 */
@property (nonatomic,copy) NSString *nodeSn;
/**
 *  Node 节点的Firmware
 */
@property (nonatomic,copy) NSString *nodeFw;
/**
 *  Node 节点的Role
 */
@property (nonatomic,copy) NSString *nodeRole;






+(getDevInfoByBLE *)shareInstanc;
@end
