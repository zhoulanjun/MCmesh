//
//  BlueToothAPI.h
//  Familie
//
//  Created by zhoulanjun on 15/6/1.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Communication.h"

//

#define TRANSFER_SERVICE_UUID   @"83443868-D0CC-D599-1D9D-E23A1911A98B"
#define TRANSFER_CHARACTERISTIC_UUID                                                                             @"E29E08F6-5C0D-1E0D-90E8-0262F9F9C613"

#define RECEIVER_CHARACTERISTIC_UUID   @"92EEB32F-470C-0074-FD63-39171798C304"




//E29E08F6-5C0D-1E0D-90E8-0262F9F9C613
//92EEB32F-470C-0074-FD63-39171798C304
//#define TRANSFER_SERVICE_UUID   @"3000"
//#define TRANSFER_CHARACTERISTIC_UUID                                                                             @"3001"
//#define RECEIVER_CHARACTERISTIC_UUID   @"3002"


typedef void(^BlueThOpen)(BOOL _isOpen);
typedef void(^SnIsLegal)(BOOL _isLegal);
typedef void (^WifiConSuc)(BOOL _isCon);
//发送NetIv 和 Netkey给云端
typedef void (^SetIvKetToNode)(BOOL _isSetIvKey);
//获取Node节点的sn type信息成功
typedef void(^GetNodeSnTypeSuc)(BOOL _getSnType);

typedef void (^CompleteBlock)(Communication *conn, id reponse);
enum
{
    CMD_setWifiSSIDAndPassword=1, //使IPC连接wifi
    CMD_getFilesInfo=2, //查询产品信息
    CMD_addNodeToMesh=3,  //把NetIv 和 NetKey 发给Node
    CMD_GetNodeSNAndNodeType=4,//查询Node产品信息 SN 和 TYPE
    CMD_setIvAndKeyForIPC=5,  //把NetIv 和 NetKey 发给IPC
};


typedef enum
{
    NOT_CONNECT,
    CONNECT_POWERON,
    CONNECT_SCAN_PERIPHERAL,
    CONNECT_SCAN_PERIPHERAL_SUCCESS,
    CONNECT_SCAN_PERIPHERAL_FAIL,
    CONNECT_SCAN_SERVICE,
    CONNECT_SCAN_SERVICE_SUCCESS,
    CONNECT_SCAN_SERVICE_FAIL,
    CONNECT_SCAN_CHARACTERISTIC,
    CONNECT_SCAN_CHARACTERISTIC_SUCCESS,
    CONNECT_SCAN_CHARACTERISTIC_FAIL,
    CONNECT_SUCCESS,
    CONNECT_FAIL_,
    CONNECT_FAIL_DELEGATE_ERROR0,
    CONNECT_FAIL_DELEGATE_ERROR1,
    
} CONNECT_ST_t;

typedef struct
{
    char *name;
    char *content;
} CMD_Param_t;

CMD_Param_t param[4];

@protocol BlueToothAPIDelegate <NSObject>

@optional
-(void)BluetoothFoundNodes;
-(void)BluetoothFound:(CBPeripheral *)finedPer;
-(void)setConnectNotification;
-(void)responseData;
-(void)connectTimeOut;
-(void)didDisconnectPeripheral;
-(void)searchProductInfoReceiveBagTimeOut;
- (void)didnotFindDevice;
@end

@protocol ConnectWifiDelegate <NSObject>
-(void)connectWifiTimeOut;
@end

@protocol IpcRegDelegate <NSObject>
-(void)IpcRegTimeOut;
-(void)IpcRegSuc;
@end

@interface BlueToothAPI : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong)CBPeripheral *curPeripheral;

@property (nonatomic,strong)CBCentralManager *manager;

//判断蓝牙是否连接
@property (nonatomic,copy)BlueThOpen bluethBlock;
@property (nonatomic,assign)BOOL bleIsOpen;

//查询产品信息完成跳进wifi页面
@property(nonatomic,copy)SnIsLegal isLegal;

//判断WiFi是否打开
@property (nonatomic,copy)WifiConSuc wifiConBlock;
//向节点设置NetIv 和 Netkey
@property (nonatomic,copy)SetIvKetToNode setIvKeyBlcok;

@property (nonatomic,copy)GetNodeSnTypeSuc getNodeSnTypeOk;

@property (nonatomic, copy)CompleteBlock completeBlock;

//节点Node的个数
@property (nonatomic,strong) NSMutableArray *Peripherals;
//存放Node节点的模型
@property (nonatomic,retain) NSMutableArray *PeriNodeModels;

@property (strong, nonatomic)NSMutableData  *mutData;
@property (strong, nonatomic)NSMutableString  *mutValueData;

@property (nonatomic, assign)CONNECT_ST_t      status;

@property (nonatomic,strong)NSMutableArray *commandDataArr;

@property (nonatomic,assign)BOOL cmdSendTimeOut;


//@property (nonatomic,strong)CBPeripheral *peripheral;
//@property (nonatomic,strong)CBCharacteristic *characteristic;

//wifi账户密码
@property (nonatomic,copy)NSString *ssidStr;
@property (nonatomic,copy)NSString *wifiPwd;


@property (nonatomic,weak)id<BlueToothAPIDelegate>  BLTDelegate;
@property (nonatomic,weak)id<ConnectWifiDelegate> wifiDelegate;
@property (nonatomic,weak)id<IpcRegDelegate> ipcRegDelegate;

+(BlueToothAPI *)shareInstan;
- (void)configUUID:(NSString *)ServiceUUID TransferUUID:(NSString *)transferUUID ListenUUID:(NSString *)listenUUID;

////初始化变量
//-(void)beginOriginParam;

//开始扫描周边
-(void)startScan;
-(void)stopScanBLE;


//连接周边
- (void)connect:(CBPeripheral *)peripheral;
- (void)cleanup;


//查询产品信息
-(void)searchProductInfo;


//连接wifi
-(void)ConnectWIFI;

//查询Node产品信息（SN TYPE）
-(void)getNodeSnType;

//拼接要发送给 "IPC节点" 的NETIV 和 NETKEY
-(void)setNetIvandNetKeyForIPC:(NSInteger)nodeId;

//拼接要发送给 "Node节点" 的NETIV 和 NETKEY
-(void)setNetIvandNetKey:(NSInteger)nodeId;

//请求验证注册鉴权信息(IPC文档)
-(void)begVerifyReg;


-(void)Pack_Cmd:(char) cmd;

- (void)prepareAndSend;

-(void)separateData:(NSData *)beSeperatedData;
@end
