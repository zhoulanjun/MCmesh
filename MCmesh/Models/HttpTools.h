//
//  HttpTools.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/12.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*
 TYPE 1.不传信息过去的 带返回的数组
 2.
 
 */

typedef void(^CommonArrBlock)(NSArray *arr);
typedef void(^CommonDicBlock)(NSDictionary *dic);
typedef void(^CommonBoolBlock)(BOOL successOrNot);
typedef void(^ErrorInfo)(NSError *error);
@interface HttpTools : NSObject

//登录
+(void)logIn:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

//不传信息过去的 带返回的数组 TYPE 1
+(void)getAllIPCCameras:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

//心跳
+(void)heartBeat;

//创建mesh网络
+(void)createMeshNetFor:(NSInteger)locIndex WithSN:(NSString *)sn WithName:(NSString *)name block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

//删除MESH网络
+(void)deleteMeshNetWithSn:(NSString *)sn  block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

// 解除关联该设备IPC
+(void)unlinkDeviceWithSn:(NSString *)snString  block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;


//请求获取Mesh信息
+(void)requestMeshInfoWithSn:(NSString *)sn block:(CommonDicBlock)block errorIn:(ErrorInfo)errorInfo;

//请求获取mesh状态信息
+(void)requestMeshStatusInfoWithSn:(NSString *)sn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

//建立节点组
+(void)createNodeGroupWithSn:(NSString *)sn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

//增加mesh节点
+(void)addMeshNode:(NSString *)nodename ForIndex:(NSInteger)locIndex  WithSn:(NSString *)sn  block:(CommonDicBlock)block errorIn:(ErrorInfo)errorInfo;

//删除mesh节点
+(void)deleteMeshNodeIpcSn:(NSString *)ipcSn  nodeSn:(NSString *)nodeSn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

// 对节点操作
+(void)operateToThisNodeIPCSn:(NSString *)ipcSn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;



// IPC注册
+(void)IPCRegblock:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

// 查询设备是否连上云端
+(void)IPCConnectCloudSn:(NSString *)sn block:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;

//查询是否被关联
+(void)orNotTobeLinkedSn:(NSString *)sn block:(CommonDicBlock)block errorIn:(ErrorInfo)errorInfo;

//请求关联设备
+(void)requestToRelateblock:(CommonBoolBlock)block errorIn:(ErrorInfo)errorInfo;



@end
