//
//  BlueToothAPI.m
//  Familie
//
//  Created by zhoulanjun on 15/6/1.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import "BlueToothAPI.h"
#import "TLVParseUtils.h"
#include <stdio.h>
#include <stdlib.h>
#import "getDevInfoByBLE.h"
#import "HttpTools.h"

#import "Interface.h"
#import "NodeModel.h"

#define OPEN_DEBUG

enum
{
    SCAN_PERIPHERAL_TIMER,
    SCAN_SERVICE_TIMER,
    GENERAL_TIMER,
    TIMER_MAX
};

enum
{
    CMD_SEND_NONE,
    CMD_SEND_START,
    CMD_SEND_CONTINUE,
    CMD_SEND_LAST,
    CMD_SEND_FINISH
};

typedef struct
{
    char data[25];
    char status;
} CMD_RESEND_t;

@interface BlueToothAPI ()
{
    NSString        *serviceUUID;
    CBPeripheral    *lastTimePeripheral;
    NSString        *sendUUID;
    NSString        *recvUUID;
    NSArray         *Characteristics;
    CBCharacteristic *transCharacteristics;
    CBCharacteristic *readCharacteristics;
    bool            need_value;
    CMD_RESEND_t    cmd_tmp;
    double          commandTO;
    double          periScanTO;
    double          periConnTO;
    int             resp_len;
    NSTimer         *myTimer;
    NSTimer         *myTimer1;
    NSTimer         *myTimer2;
    NSTimer         *myTimer3;//connect 超时计时器
//    char            *cmdtmp;
    bool isFirst;
    NSInteger arrNum;
    dispatch_queue_t _globalQueue1;
    
    char identifierForBLE;
    
    //失败重连三次
    NSInteger reConnectCount;
    
    
    
}
@end

@implementation BlueToothAPI

@synthesize manager;
@synthesize Peripherals;
@synthesize PeriNodeModels;
@synthesize mutData;
@synthesize status;


+(BlueToothAPI *)shareInstan
{
    static BlueToothAPI *shareInstan = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        shareInstan = [[self alloc] init];
    });
    
    return shareInstan;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        manager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
        Peripherals=[NSMutableArray array];
        PeriNodeModels=[NSMutableArray array];

        Characteristics = [[NSMutableArray alloc] init];

        
        self.mutData=[[NSMutableData alloc]init];
        self.mutValueData=[[NSMutableString alloc]init];
        
        need_value=NO;
        resp_len=0;
//        cmdtmp = malloc(1024);
        isFirst=YES;
        arrNum=1;
        
        [self configUUID:TRANSFER_SERVICE_UUID
            TransferUUID:TRANSFER_CHARACTERISTIC_UUID
              ListenUUID:RECEIVER_CHARACTERISTIC_UUID];
        [self configTimeout:10.0f peripheralConnectTimeout:5.0f CommandTimeout:3.0f];
        
        status = NOT_CONNECT;
        _globalQueue1=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
    }
    return self;
}


#pragma mark- 1-初始化变量
- (void)configUUID:(NSString *)S_UUID TransferUUID:(NSString *)TC_UUID ListenUUID:(NSString *)LC_UUID
{
    serviceUUID = S_UUID; // 扫描 kCBAdvDataServiceUUIDs
    sendUUID = TC_UUID;
    recvUUID = LC_UUID;
}
- (void)configTimeout:(double)pScan peripheralConnectTimeout:(double)pConnect CommandTimeout:(double)cmdTimeout
{
    periScanTO = pScan;
    periConnTO = pConnect;
    commandTO = cmdTimeout;
}

#pragma mark- 2-判断本机蓝牙是否开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state==CBCentralManagerStatePoweredOn)
    {
        status = CONNECT_POWERON;
        self.bleIsOpen=YES;
    }else
    {
        NSLog(@"本机蓝牙没有开启!\n");
        self.bleIsOpen=NO;
    }
}

//*************************************************

-(void)stopScanBLE
{
    [manager stopScan];
}

#pragma mark- 2.1-开始扫描周边--》》》》定时方法待用
-(void)startScan
{
//    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBCentralManagerScanOptionAllowDuplicatesKey, nil];

//      [manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        
        [manager scanForPeripheralsWithServices:nil options:nil];

        [self start_timer:0 timeout:20 selector:@selector(didnot_find_device)];
}

#pragma mark- 3-发现周边
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"XXXXXXXXXXXXXX%@===%@==广播的数据字典%@",peripheral.name,RSSI,advertisementData);
    if (myTimer)
    {
        [self clear_timer:0];
    }
    NSData *factoryData=advertisementData[@"kCBAdvDataManufacturerData"];
    NSLog(@"XXX factoryData XXX%@",factoryData);
    
    if (factoryData)
    {
//       kCBAdvDataManufacturerData = <5aa50001 00>;
        Byte *testByte = (Byte *)[factoryData bytes];

        if (testByte[0]==0x5a && testByte[1]==0xa5 && testByte[2]==0x00)
        {
//            testByte[3]==0x01  Gateway Node
            if (testByte[3]==0x01)
            {
                //        testByte[4]==0x00  没有被创建Mesh网络
                if (testByte[4]==0x00 &&[[User sharedUser].addDeviceOrSetWifi isEqualToString:@"ADDDEV"])
                {
                    [self perfomDelegateMethod:peripheral];
                }          //        testByte[4]==0x01  已经被创建Mesh网络
                else if (testByte[4]==0x01 &&[[User sharedUser].addDeviceOrSetWifi isEqualToString:@"CONCERDEV"])
                {
                    [self perfomDelegateMethod:peripheral];
                }
            }else
            {
                //                0x0002:Socket Node
                //                0x0003:Sensor Node
                //                0x0004:Keypad Node
                //                testByte[3]==0x01
                  // 周边节点Node
                
                     if ([[User sharedUser].addDeviceOrSetWifi isEqualToString:@"CONCERNODE"])
                     {
                         if (testByte[4]==0x00)
                         {
                            if (![Peripherals containsObject:peripheral])
                              {
                                  NodeModel *node=[[NodeModel alloc]init];
                                  switch (testByte[3])
                                  {
                                   case 0x02:
                                      node.peripheralName=@"socket";
                                      break;
                                   case 0x03:
                                      node.peripheralName=@"sensor";
                                      break;
                                   case 0x04:
                                     node.peripheralName=@"keypad";
                                     break;
                                  }
                                 node.peripheral=peripheral;
                             
                                 [Peripherals addObject:peripheral];
                                 [PeriNodeModels addObject:node];
                                  NSLog(@"%@",peripheral);
                             //一旦找到设备就开始connect
                             [self perfomDelegateMethodForFindNodes];
                             NSLog(@"节点的周边设备数：%ld----节点模型的数组：-%@----新加入的节点信息--%@",Peripherals.count,PeriNodeModels,peripheral);
                         }
                     }
                 }
            }
        }
    }
}


-(void)perfomDelegateMethodForFindNodes
{
    
    if ([_BLTDelegate respondsToSelector:@selector(BluetoothFoundNodes)])
    {
        [_BLTDelegate BluetoothFoundNodes];
    }else
    {
        NSLog(@"-->the delegate function: -(void)BluetoothFound isn't implemented correctly!");
    }
    


}

-(void)perfomDelegateMethod:(CBPeripheral *)peripheral
{
    if ([_BLTDelegate respondsToSelector:@selector(BluetoothFound:)])
    {
        [_BLTDelegate BluetoothFound:peripheral];
    }else
    {
        NSLog(@"-->the delegate function: -(void)BluetoothFound isn't implemented correctly!");
    }


}


#pragma mark- 4-连接周边
- (void)connect:(CBPeripheral *)peripheral
{
    _curPeripheral=peripheral;
    //    [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnNotificationKey]];
    
    NSLog(@"===blue tooh name==%@",peripheral.name);
    [manager connectPeripheral:peripheral options:nil];
    
    //超过20秒连不上视为超时机制
//    if ([[User sharedUser].addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
//    {
//        
//    }else
//    {
//        [self start_timer:3 timeout:20 selector:@selector(did_Connect_timeout)];
//    }
    
}

#pragma mark- 4.1-连接周边成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接周边成功");
    reConnectCount=0;
    //如果连上设备就把超时的定时器invalidate
    if (myTimer3)
    {
        [self clear_timer:3];
    }
    [peripheral setDelegate:self];
    if (serviceUUID)
    {
        status = CONNECT_SCAN_SERVICE;
        
         [peripheral discoverServices:@[[CBUUID UUIDWithString:serviceUUID]]];
          NSLog(@"%@",peripheral);
    }else
    {
        [peripheral discoverServices:nil];
    }
}


-(void)beginIPCRegToCloud
{
     //IPC注册
    
        [HttpTools IPCRegblock:^(BOOL successOrNot) {
            
            
            if (successOrNot == YES)
            {
                
                if (_isLegal)
                {
                    _isLegal(YES);
                }
                
            }else
            {
                
                if (_isLegal)
                {
                    _isLegal(NO);
                }
            }
        } errorIn:^(NSError *error) {
            
        }];
}

#pragma mark- 4.2-连接周边失败

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    reConnectCount++;
    if (myTimer)
    {
        [self clear_timer:0];
        
    }
    
    //失败重连3次
    if (reConnectCount <=3 )
    {
        [self connect:_curPeripheral];

    }else
    {
        reConnectCount=0;
//        @"尝试重连3次，依然没有连上"

        
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    _curPeripheral = nil;
    [self.mutData resetBytesInRange:NSMakeRange(0, self.mutData.length)];
    [self.mutData setLength:0];
    
    User *user=[User sharedUser];
    
    //如果已经断开链接了超时计时器还存在要清除
    if (myTimer3)
    {
        [self clear_timer:3];
    }
    if (![user.disconnectByWho isEqualToString:@"byUser"])
    {
        user.connectTime ++;

    }
    
    
    isFirst=YES;
    arrNum=1;
    
    // =4 时return 通知前方 弹出提示框
        if (user.connectTime == 3)
      {
         [self did_disconnect_per];
         user.connectTime=1;
         return;
      }else if(![user.disconnectByWho isEqualToString:@"backTo"] && ![user.disconnectByWho isEqualToString:@"byUser"])
     {
        //返回上一个页面引起的断开不需要重连接 其他情况（选择另外设备引起的断开和系统自动断开的要重连机制）
    //        [self connect:peripheral];
     }
    
    
    if ([user.disconnectByWho isEqualToString:@"byUser"])
    {
        user.disconnectByWho=nil;
    }
    
}


#pragma mark- 取消周边连接
- (void)cleanup
{
//    if (!_curPeripheral.isConnected)
//    {
//        return;
//    }
    
    if (_curPeripheral.services != nil)
    {
        for (CBService *service in _curPeripheral.services)
        {
            if (service.characteristics != nil)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]])
                    {
                        if (characteristic.isNotifying)
                        {
                            // It is notifying, so unsubscribe
                            [_curPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    if (_curPeripheral) {
        [manager cancelPeripheralConnection:_curPeripheral];
    }
}


#pragma mark- 5-发现服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSInteger found=0;
    if (error)
    {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        status=CONNECT_SCAN_SERVICE_FAIL;
        return;
    }

    NSLog(@"%@",peripheral.services);
    

    status=CONNECT_SCAN_SERVICE_SUCCESS;
    
    NSLog(@"* * * * * *peripheral.services  %@* * * * * *------* * * * * *peripheral.name  %@ * * * * * *",peripheral.services,peripheral.name);
    
    
    
    for (CBService *service in peripheral.services)
    {

        NSLog(@"%@",[NSString stringWithFormat:@" * * * * * *service.UUID.data * * * * * *%@",[service.UUID.data description]]);
        
        NSLog(@" * * * * * *servie is * * * * * *%@",service);

        
        if ([service.UUID.UUIDString isEqualToString:serviceUUID])
//            if (serviceUUID)

        {
            [peripheral discoverCharacteristics:nil forService:service];
//              [self clear_timer:0];
            found = 1;
        }
        else
        {
            [peripheral discoverCharacteristics:nil forService:service];
            
            NSLog(@"Error transfer UUID is not config correctly! \n");
        }
    }
}

#pragma mark- 6-发现特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    char ch_status=0;
    if (error)
    {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        status = CONNECT_SCAN_CHARACTERISTIC_FAIL;
        return;
    }
    
    
    Characteristics = service.characteristics;
    NSLog(@"* * * * * *service.characteristics * * * * * *%@",service.characteristics);
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSString *str;
        str=[NSString stringWithFormat:@"* * * * * *characteristic %@* * * * * *characteristic.UUID.data.description %@",characteristic,characteristic.UUID.data.description];
        NSLog(@"%@",str);
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:sendUUID]])
        {
            transCharacteristics=characteristic;
            ch_status|=1;
            NSLog(@"Transfer Characteristic is found! \n");
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:recvUUID]])
        {
            readCharacteristics=characteristic;
            
#warning 二选一!!!!!!!!!!!!!
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            didUpdateNotificationStateForCharacteristic
            NSLog(@"characteristic.isNotifying===%d",characteristic.isNotifying);
            NSLog(@"二选一!!!!!!!!!!!!!%@",characteristic);
//             [peripheral readValueForCharacteristic:characteristic];
//            didUpdateValueForCharacteristic
            ch_status|=2;
            
            NSLog(@"receiver Characteristic is found! \n");
        }
        NSLog(@"%d",characteristic.isNotifying);
    }
    if(ch_status==3)
    {
        status = CONNECT_SCAN_CHARACTERISTIC_SUCCESS;
        // [peripheral setNotifyValue:YES forCharacteristic:transCharacteristics];
        [self stopScanBLE];
        NSLog(@"找到该设备的所有特征-------------------------");
    }
    else
    {
        status = CONNECT_SCAN_CHARACTERISTIC_FAIL;
    }
    if((ch_status&1)==0)
    {
        NSLog(@"Error:the transfer Characteristic is not found! \n");
    }
    if(recvUUID)
    {
        if((ch_status&2)==0)
        {
            NSLog(@"Error:the listen Characteristic is not found! \n");
        }
    }
//    Node节点信息
    if ([[User sharedUser].addDeviceOrSetWifi isEqualToString:@"CONCERNODE"])
    {

        NSLog(@"查询Node节点的SN和TYPE  CMD_GetNodeSNAndNodeType ");
        [self getNodeSnType];
        [self Pack_Cmd:CMD_GetNodeSNAndNodeType];
    }else
    {
        //连接设备成功就开始，查询IPC设备信息
        //拼接要发送的TLV
        [self searchProductInfo];
        [self Pack_Cmd:CMD_getFilesInfo];
    }
}


#pragma mark- 写值成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"_______________写操作完成________________________%@ %@",peripheral.name,peripheral);
    NSString *str;
    str=[NSString stringWithFormat:@"* * * * * *characteristic %@* * * * * *characteristic.UUID.data.description %@",characteristic,characteristic.UUID.data.description];
    
    NSLog(@"%@",str);
    
    
    if (error)
    {
        NSLog(@"======发送数据错误=========================");
        NSLog(@"==写值错误=====%@",error.userInfo);
    }else
    {
        NSLog(@"发送数据成功");
        
        //        NSLog(@"已经写值成功！-----%@",characteristic);
        //        NSString *str1=[NSString stringWithFormat:@"已经写值成功！-----%@",characteristic];
        //        UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"写数据" message:str1 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        //        [al show];
    }
    
}


#pragma mark-  读数据-----
//    http://doc.okbase.net/kw-ios/archive/94529.html

// http://www.cnblogs.com/visen-0/p/4013119.html


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error changing notification state: %@--", error);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSLog(@"Received: %@", stringFromData);
    
    
    NSLog(@"%@",characteristic);
    
    
    
    // Notification has started
    //    if (characteristic.isNotifying)
    //    {
    //        NSLog(@"Notification began on %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    //
    //
    //        [curPeripheral readValueForCharacteristic:characteristic];
    //
    //        //调用上面的方法后 会调用到代理的- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    //
    //    }
    //    // Notification has stopped
    //    else
    //    {
    //        // so disconnect from the peripheral
    //        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
    //        [manager cancelPeripheralConnection:peripheral];
    //    }
    
    
    
    
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:recvUUID]])
    {
        return;
    }else
    {
        [peripheral readValueForCharacteristic:characteristic];
    }
}





#pragma mark- 7-与外设做数据交互
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    NSString *stringFromData=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSLog(@"收到的字串%@----原始值%@-----周边%@",stringFromData,characteristic.value,characteristic);
    
    //判断下如果是最后一包就要 解析收到的产品信息
    NSString *judgeStr=[[self hexadecimalString:characteristic.value] substringWithRange:NSMakeRange(0, 2)];
    
    NSLog(@"judgeStr－－－－－%@",judgeStr);
    
    //设置为yes表示没有超时
    _cmdSendTimeOut=YES;
    [self clear_timer:1];

//    if (isFirst)
//    {
//        isFirst =NO;
//        return;
//        
//    }else
//    {
        if ([stringFromData isEqualToString:@"response"])
        {
            [self cmd_response];

            
        }else if ([stringFromData isEqualToString:@"errorcode=00"])
        {
            NSLog(@"%@----%@-----%@",stringFromData,characteristic.value,characteristic);
            
            //错误信息，根据错误码来定义
            arrNum=1;
            
        }else if([judgeStr isEqualToString:@"fe"]||[judgeStr isEqualToString:@"55"]||[judgeStr isEqualToString:@"00"])
        {
            
            NSLog(@"******************************************************");
            
            [_curPeripheral writeValue:[self dataWithHexstring:@"reback"]   forCharacteristic:transCharacteristics type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"===%@",_curPeripheral);
            
            if (![judgeStr isEqualToString:@"00"])
            {
                [self start_timer:1 timeout:20 selector:@selector(did_send_timeout1:)];
            }
            
            NSData *newData=[self cutHeadBodyTail:characteristic.value];
            NSLog(@"%@  ===newData===%@ ",self.mutData,newData);
            [self.mutData appendData:newData];
            
            if ([judgeStr isEqualToString:@"00"])
            {
                NSLog(@"最终 收到的 mutData%@  === ",self.mutData);

                [self analysisTLVForIPCAndWifi];
            }
        }
    
//    }
 }

#pragma mark- ==ONE== 将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data
{
    NSString* result;
    const unsigned char *dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer)
    {
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for(int i = 0; i < dataLength; i++)
    {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

#pragma mark- ==TWO== 去掉收到的数据的头部
-(NSData *)cutHeadBodyTail:(NSData *)data
{
    return [data subdataWithRange:NSMakeRange(1, data.length-1)];
}

#pragma mark- ==THREE== 收到的TLV解析（IPC设备信息 +  wifi）
-(void)analysisTLVForIPCAndWifi
{
    //验证checksum，解析产品信息，保存产品信息
    NSLog(@"self.mutData----%@",self.mutData);
    unsigned char *totalValueBuffer=(unsigned char *)[self.mutData bytes];
    NSLog(@"totalValueBuffer====%s",totalValueBuffer);
    
    int checkSum = 0;
    for (int index = 0; index < self.mutData.length-2; index ++)
    {
        checkSum +=totalValueBuffer[index];
    }
    NSLog(@"=====%d",checkSum);
    
    unsigned char *p = (unsigned char *)&checkSum;
    // 02  4a
    NSLog(@"===%x  ====%x",(checkSum&0xff00)>>8,(checkSum&0x00ff));
    NSLog(@"===%x  ====%x",*(p+1),*p);
    
    NSLog(@"%x---%x",totalValueBuffer[self.mutData.length-2],totalValueBuffer[self.mutData.length - 1]);
    if (totalValueBuffer[self.mutData.length-2] == *(p+1) && totalValueBuffer[self.mutData.length - 1] == *p )
    {
        NSLog(@"check sum 正确");
        
        NSString *mutdataStr=[self hexadecimalString:self.mutData];
        TLVParseUtils*s = [[TLVParseUtils alloc] init];
    
        NSArray *tlvArr =  [s saxUnionField55_2List:mutdataStr];
        
        //用来存储通过蓝牙
        getDevInfoByBLE *getInfo = [getDevInfoByBLE shareInstanc];
        NSLog(@"%@---%ld",tlvArr,tlvArr.count);
        for (TLV *tlv in tlvArr)
        {
            NSLog(@"%c----%@--%ld--%@",identifierForBLE,tlv.tag,tlv.length,tlv.value);
            
            NSLog(@"  ^^^^^^   identifierForBLE======%c",identifierForBLE);

            //只需要取value就可以了
            switch (identifierForBLE)
            {
                    
                case CMD_getFilesInfo:
                {
                    if ([tlv.tag isEqualToString:@"58"])
                    {
                        //查询IPC设备信息返回的值
                        NSLog(@"查询IPC设备信息返回的值 value is %@",tlv.value);
                        NSString *snStr=[tlv.value substringWithRange:NSMakeRange(0, 64)];
                        getInfo.bleGetSN=[self stringFromHexString:snStr];
                        getInfo.bleGetProductCode=[tlv.value substringWithRange:NSMakeRange(16, 4)];
                        getInfo.bleGetProduceTime=[tlv.value substringWithRange:NSMakeRange(20, 14)];
                        getInfo.bleGetVersionNum=[tlv.value substringWithRange:NSMakeRange(34, 8)];
                        
                        NSLog(@"bleGetSN=%@----bleGetProductCode=%@------bleGetProduceTime=%@------bleGetVersionNum=%@",getInfo.bleGetSN,getInfo.bleGetProductCode,getInfo.bleGetProduceTime,getInfo.bleGetVersionNum);
                        
                        //存起来，写入Plist文件
                        
                
                    }else if([tlv.tag isEqualToString:@"61"])
                    {
                        if (tlv.length==8)
                        {
                            //秘钥-
                            NSLog(@"秘钥- value is %@",tlv.value);
                            getInfo.bleGetEncryptKey=tlv.value;

                        }else
                        {
                            //请求产品信息返回的加密数据
                            NSLog(@"请求产品信息返回的加密数据 value is %@",[tlv.value substringWithRange:NSMakeRange(2,tlv.length*2-2)]);
                            getInfo.bleGetEncryptInfo =[self stringFromHexString:[tlv.value substringWithRange:NSMakeRange(2,tlv.length*2-2)]];
                            NSLog(@"请求产品信息返回的加密数据 value is %@---bleGetEncryptInfo=%@",[tlv.value substringWithRange:NSMakeRange(2,tlv.length*2-2)],getInfo.bleGetEncryptInfo);
                            
                            //暂时放在这里了
                            //如果是添加设备（不是修改WIFI）,查询产品信息成功,开始IPC注册,验证SN的合法性
                            if (![[User sharedUser].addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
                            {
                                [self beginIPCRegToCloud];

                            }else if([[User sharedUser].addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
                            {
                            }

                        }
                    }
                }
                    break;
                case CMD_setWifiSSIDAndPassword:
                {
                    if ([tlv.tag isEqualToString:@"e0"])
                    {
                        //连接wifi返回的值  <560120e0 0100f002 024a>
                        NSLog(@"连接wifi返回的值 value is %@",tlv.value);
                        if ([tlv.value isEqualToString:@"00"])
                        {
                            _wifiConBlock(YES);
                        }else
                        {
                           _wifiConBlock(NO);
                        }
                    }
                }
                    break;
                case CMD_addNodeToMesh:
                {//CMD_addNodeToMesh   set Iv 和 Key
                    
                    if ([tlv.tag isEqualToString:@"e0"])
                    {
                        //set Iv 和 Key  <560120e0 0100f002 024a>
                        NSLog(@"set Iv 和 Key value is %@",tlv.value);
                        if ([tlv.value isEqualToString:@"00"])
                        {
                            if (_setIvKeyBlcok)
                            {
                                _setIvKeyBlcok(YES);
                            }
                        }else
                        {
                            if (_setIvKeyBlcok)
                            {
                                _setIvKeyBlcok(NO);
                            }
                        }
                    }

                    
                }
                    break;
                case CMD_GetNodeSNAndNodeType:
                {
                   
                    if ([tlv.tag isEqualToString:@"5c"])
                    {
                        
                        NSLog(@"查询Node返回的值 value is %@",tlv.value);
                        
                        NSMutableString *nodeMacString=[NSMutableString string];
                        
                        for (NSInteger i=0; i<6; i++)
                        {
                            NSString * singleMac=[tlv.value substringWithRange:NSMakeRange(4+2*i, 2)];
                            if (i<5)
                            {
                                singleMac=[NSString stringWithFormat:@"%@:",singleMac];
                            }
                            [nodeMacString appendString:singleMac];
                        }
                        getInfo.nodeMac=nodeMacString;
                        
                        
                        getInfo.nodeType=[tlv.value substringWithRange:NSMakeRange(18, 2)];
                        
                        getInfo.nodeSn=[self stringFromHexString:[tlv.value substringWithRange:NSMakeRange(20, 32)]];
                        
                        NSLog(@"查询节点 Node的nodeMac=%@----nodeType=%@------nodeSn=%@---",getInfo.nodeMac,getInfo.nodeType, getInfo.nodeSn);
                        
                        if (_getNodeSnTypeOk)
                        {
                            _getNodeSnTypeOk(YES);
                        }
                      
                    }
                    
                 }
                    break;
                case CMD_setIvAndKeyForIPC:
                {
                    if ([tlv.tag isEqualToString:@"e0"])
                    {
                        //连接wifi返回的值  <560100e0 0100f002 022a>
                        NSLog(@"设置NetIv 和 netKey给IPC节点 value is %@",tlv.value);
                        if ([tlv.value isEqualToString:@"00"])
                        {
                            NSLog(@"设置NetIv 和 netKey给IPC节点成功");
                        }else
                        {
                        }
                    }
                }
                    break;
            }
        }
    }else
    {
        
        
    }
}

#pragma mark- 将传入的NSString类型转换成NSData并返回
- (NSData*)dataWithHexstring:(NSString *)hexstring
{
    const char *hexStr=[hexstring UTF8String];
    NSLog(@"%s",hexStr);
    
    NSData* aData;
    return aData = [hexstring dataUsingEncoding: NSASCIIStringEncoding];
}


#pragma mark - 2 把@"4950433031"   @"IPC01"
-(NSString *)stringFromHexString:(NSString *)hexString
{ //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2)
    {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    
//    NSData *data = [NSData dataWithBytes:(const void *)cmd length:hexLength];
//    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

#pragma mark -拼接要发送给 "Node节点" 的NETIV 和 NETKEY
-(void)setNetIvandNetKey:(NSInteger)nodeId
{
    NSData * data = [self addNodeToMesh:nodeId for:@"NODE"]; // Node节点信息data
    NSLog(@"Node节点信息data   %@",data);
    [self separateData:data]; //在data里面分包FE 55 00 并发包
}

#pragma mark -拼接要发送给 "IPC节点" 的NETIV 和 NETKEY
-(void)setNetIvandNetKeyForIPC:(NSInteger)nodeId
{
    NSData * data = [self addNodeToMesh:nodeId for:@"IPC"]; // Node节点信息data
    NSLog(@"Node节点信息data   %@",data);
    [self separateData:data]; //在data里面分包FE 55 00 并发包
}


#pragma mark -查询Node节点的NodeSn NodeType
-(void)getNodeSnType
{
    NSData *data = [self getSnTypeData];
    NSLog(@"查询Node节点的NodeSn NodeType的data   %@",data);
    [self separateData:data]; //在data里面分包FE 55 00 并发包
}




#pragma mark- NO.1-查询产品信息/拼接要发送的TLV
-(void)searchProductInfo
{
    NSData * data = [self getSearchProductInfoBytes]; //查询产品信息data
    [self separateData:data]; //在data里面分包FE 55 00 并发包
}
#pragma mark- NO.1-读取固定mac 地址
-(void)serachMacAndModel
{
    NSData *data=[self getMacAndModelInfo];//查询固定mac地址和model信息
    [self separateData:data]; //在data里面分包FE 55 00 并发包
}

#pragma mark- NO.1-连接WIFI/拼接要发送的TLV
-(void)ConnectWIFI
{
    NSData * data = [self getIPCConnectWifiBytes]; //查询产品信息data
    NSLog(@"%@",data);
    [self separateData:data]; //在data里面分包FE 55 00 并发包
    NSLog(@"%@",_commandDataArr);
}

#pragma mark- NO.2 查询固定mac地址和model信息
-(NSData *)getMacAndModelInfo
{
    NSData *commadData = nil;
    
    unsigned char cmd[1024];
    
    //测试
    cmd[0] = 0x56;//
    cmd[1] = 0x01;
    cmd[2] = 0x00;
    
    cmd[3] = 0x61;
    
    //长度
    cmd[4] = 0x02;
    cmd[5] = 0x05;
    cmd[6] = 0x01;
    cmd[7] = 0xF0;
    cmd[8] = 0x02;
    
//    **************************************
    
    int checkSum = 0;
    
    for (int index = 0;index <= 8;index ++)
    {
        checkSum += cmd[index];
    }
    
    unsigned char *p = (unsigned char *)&checkSum;
    cmd[9]  = *(p+1);
    cmd[10]  = *p;
    commadData = [NSData dataWithBytes:cmd length:11];
    NSLog(@"===查询固定mac地址和model信息===%@",commadData);
    return commadData;
}

#pragma mark-  拼接NetIv 和 NetKey
-(NSData *)addNodeToMesh:(NSInteger)nodeId for:(NSString *)periperal
{
    NSData *commadData = nil;
    unsigned char cmd[1024];
    //测试
    cmd[0] = 0x56;//
    cmd[1] = 0x01;
    cmd[2] = 0x20;
    cmd[3] = 0x61;
    //长度
    cmd[4] = 0x00;
     cmd[5] = 0x07;
     cmd[6] = 0x01;
    if (nodeId==0)
    {
        //IPC 0x00
        cmd[7] = 0x00;
    }else
    {
#warning NodeID 一个节点 暂定为1  1-199
      cmd[7] = nodeId;
    }

    if ([periperal isEqualToString:@"IPC"])
    {
        [self getRandomStr:8 for:@"netIv"];

    }
    
    unsigned char *bufferIV = (unsigned char*)[[User sharedUser].netIVData bytes];
    
    for (int ind = 0; ind < [User sharedUser].netIVData.length; ind++)
    {
        cmd[8 + ind] = bufferIV[ind];
        NSLog(@"cmd[%d]==%0x",8+ind,cmd[8+ind]);
    }
    
    if ([periperal isEqualToString:@"IPC"])
    {
        [self getRandomStr:16 for:@"netKey"];
    }
    
    unsigned char *bufferKey = (unsigned char*)[[User sharedUser].netKeyData bytes];
    
    for (int ind = 0; ind < [User sharedUser].netKeyData.length; ind++)
    {
        cmd[16 + ind] = bufferKey[ind];
        NSLog(@"cmd[%d]==%0x",16+ind,cmd[16+ind]);
    }

    cmd[4]=27;
    //计算checksum
    cmd[32] = 0xF0;
    cmd[33] = 0x02;
    
    int checkSum = 0;
    
    for (int index = 0;index <= 33;index ++)
    {
        checkSum += cmd[index];
    }
    
    unsigned char *p = (unsigned char *)&checkSum;
    cmd[34]  = *(p+1);
    cmd[35]  = *p;
    commadData = [NSData dataWithBytes:cmd length:36];
    
    NSLog(@"=拼接NetIv 和 NetKey=====%@",commadData);
    return commadData;

}
#pragma mark -查询Node SN Type的data
-(NSData *)getSnTypeData
{
    NSData *commadData = nil;
    
    unsigned char cmd[1024];
    
    //测试
    cmd[0] = 0x56;//
    cmd[1] = 0x01;
    cmd[2] = 0x00;
    
    cmd[3] = 0x61;
    //长度
    cmd[4] = 0x02;
    cmd[5] = 0x06;
    cmd[6] = 0x01;
    
    //计算checksum
    cmd[7] = 0xF0;
    cmd[8] = 0x02;
    
    int checkSum = 0;
    
    for (int index = 0;index <= 8;index ++)
    {
        checkSum += cmd[index];
    }
    
    unsigned char *p = (unsigned char *)&checkSum;
    cmd[9]  = *(p+1);
    cmd[10]  = *p;
    commadData = [NSData dataWithBytes:cmd length:11];
    
    
    
    
    
    
    
    
    NSLog(@"查询Node SN Type的data=====%@",commadData);
    return commadData;
}


#pragma mark- NO.2 查询产品信息data
-(NSData *)getSearchProductInfoBytes
{
    NSData *commadData = nil;
    
    unsigned char cmd[1024];
    
    //测试
    cmd[0] = 0x56;//
    cmd[1] = 0x01;
    cmd[2] = 0x00;
    
    cmd[3] = 0x61;
    
    //长度
    cmd[4] = 0x00;
    
    //用户名
    cmd[5] = 0x00;
    
    //zhoulanjun
    NSString *string = @"apps";
    NSData *namaData = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *buffer = (unsigned char*)[namaData bytes];
    for (int index = 0; index < namaData.length; index ++)
    {
        cmd[6 + index] = buffer[index];
        NSLog(@"%0x",cmd[6+index]);
    }
    //password
    cmd[6+namaData.length] = 0x00;
    
    //--------------------------------------------------
    
    NSString *password= @"123456";
    NSData *pwdData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"pwdData====%@",pwdData);
    
    unsigned char *buffer2 = (unsigned char*)[pwdData bytes];
    NSLog(@"buffer2====%s",buffer2);
    
    for (int index = 0; index < pwdData.length; index ++)
    {
        cmd[7 + index+namaData.length] = buffer2[index];
        NSLog(@"%0x",cmd[6+index+namaData.length]);
    }
    
    cmd[7+namaData.length+pwdData.length] = 0x00;
    
    cmd[4] = 3 + namaData.length + pwdData.length;
    
    //计算checksum
    cmd[7+namaData.length+pwdData.length+1] = 0xF0;
    cmd[7+namaData.length+pwdData.length+2] = 0x02;
    
    int checkSum = 0;
    
    for (int index = 0;index <= 7+namaData.length+pwdData.length+2;index ++)
    {
        checkSum += cmd[index];
    }
    
    unsigned char *p = (unsigned char *)&checkSum;
    cmd[7+namaData.length+pwdData.length+3]  = *(p+1);
    cmd[7+namaData.length+pwdData.length+4]  = *p;
    
    
    commadData = [NSData dataWithBytes:cmd length:7+namaData.length+pwdData.length+4+1];
    
    NSLog(@"=查询产品信息=====%@",commadData);
    return commadData;
}



#pragma mark- NO.2 连接WIFI
-(NSData *)getIPCConnectWifiBytes
{
    NSData *commadData = nil;
    
    unsigned char cmd[1024];
    
    //测试
    cmd[0] = 0x56;
    cmd[1] = 0x01;
    cmd[2] = 0x20;
    
    cmd[3] = 0x61;
    //长度
    
    cmd[4] = 0x00;
    //用户名
    
    cmd[5] = 0x01;
    
    //WIFI账号
    NSString *string = self.ssidStr;
    //    NSString *string = @"1";
    
    
    NSData *ssidData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"ssidData====%@",ssidData);
    
    unsigned char *buffer = (unsigned char*)[ssidData bytes];
    NSLog(@"buffer====%s",buffer);
    
    for (int index = 0; index < ssidData.length; index ++)
    {
        cmd[6 + index] = buffer[index];
        NSLog(@"%0x",cmd[6+index]);
    }
    
    cmd[6+ssidData.length] = 0x00;
    
    //--------------------------------------------------
    
    
    //wifi密码
    NSString *password= self.wifiPwd;
    //    NSString *password= @"1";
    
    NSData *pwdData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"pwdData====%@",pwdData);
    
    unsigned char *buffer2 = (unsigned char*)[pwdData bytes];
    NSLog(@"buffer2====%s",buffer2);
    
    for (int index = 0; index < pwdData.length; index ++)
    {
        cmd[7 + index+ssidData.length] = buffer2[index];
    }
    
    cmd[7+ssidData.length+pwdData.length] = 0x00;
    
    cmd[4] = 3 + ssidData.length + pwdData.length;
    
    //计算checksum
    cmd[7+ssidData.length+pwdData.length+1] = 0xF0;
    cmd[7+ssidData.length+pwdData.length+2] = 0x02;
    
    int checkSum = 0;
    
    for (int index = 0;index <= 7+ssidData.length+pwdData.length+2;index ++)
    {
        checkSum += cmd[index];
    }
    
    
    unsigned char *p = (unsigned char *)&checkSum;
    cmd[7+ssidData.length+pwdData.length+3]  = *(p+1);
    cmd[7+ssidData.length+pwdData.length+4]  = *p;
    
    commadData = [NSData dataWithBytes:cmd length:7+ssidData.length+pwdData.length+4+1];
    
    NSLog(@"======%@",commadData);
    
    return commadData;
    
}

#pragma mark- NO.2 注册鉴权
-(NSData *)getBegVerifiyRegBytes
{
    NSData *commadData = nil;
    
    unsigned char cmd[1024];
    
    //测试
    cmd[0] = 0x56;
    cmd[1] = 0x01;
    cmd[2] = 0x20;
    
    cmd[3] = 0x60;
    cmd[4] = 0x02;
    
    //要计算的Tag为61的值
    cmd[5] = 0x00;
    cmd[6] = 0x00;
    
    cmd[7] = 0x61;
    cmd[8] = 0x00;
    cmd[9] = 0x02;
//    
    //把RndIPC经过某种算法生成RndCloudIPC
    User *u=[User sharedUser];
//    NSString *string = u.authorize;
    NSString *string = nil;

    NSInteger StrLen=string.length+1;
    
    NSLog(@"%@--%ld",string,StrLen);
    
    unsigned char *strLenth = (unsigned char *)&StrLen;
    
    cmd[5]  =  *(strLenth+1);
    NSLog(@"===5==%x",cmd[5]);
    cmd[6]  =  *strLenth;
     NSLog(@"==6===%x",cmd[6]);
    
    
    NSData *ssidData = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char *buffer = (unsigned char*)[ssidData bytes];
    
    NSLog(@"buffer====%s",buffer);
    
    for (int index = 0; index < ssidData.length; index ++)
    {
        cmd[10 + index] = buffer[index];
        NSLog(@"10+index=%d----%x",10+index,cmd[10+index]);
    }
    
    //--------------------------------------------------
    
    cmd[10+ssidData.length] = 0xF0;
    
    
    //计算checksum
    cmd[10+ssidData.length+1] = 0x02;
    
    long int checkSum = 0;
    
    for (int index = 0;index <= 10+ssidData.length+1;index ++)
    {
        checkSum += cmd[index];
        NSLog(@"=ind%d==%x===%0lx",index,cmd[index],checkSum);
    }
    unsigned char *p = (unsigned char *)&checkSum;
    
    cmd[10+ssidData.length+2]  = *(p+1);
    cmd[10+ssidData.length+3]  = *p;
    
    
    
    commadData = [NSData dataWithBytes:cmd length:10+ssidData.length+4];
    
    NSLog(@"======%@",commadData);
    
    return commadData;
    
}

#pragma mark - NO.3 在data里面分包FE 55 00 并发包  此处最好返回一个拼好的数组
-(void)separateData:(NSData *)beSeperatedData
{
    [_commandDataArr removeAllObjects];
    
//    unsigned char cmd[2] = {0xFE, 0x00};
    //    NSMutableData * commadDataOne = [NSMutableData dataWithBytes:cmd length:1];
    //   NSMutableData * commadDataThr = [NSMutableData dataWithBytes:&cmd[1] length:1];
    
    
    char cmd1[1];
    char cmd3[1];
    cmd1[0]=0xFE;
    cmd3[0]=0x00;
    
    NSMutableData * commadDataOne = [NSMutableData dataWithBytes:cmd1 length:1];
    NSMutableData * commadDataThr = [NSMutableData dataWithBytes:cmd3 length:1];


    NSInteger lth=beSeperatedData.length;
    NSLog(@"%@----%ld",beSeperatedData,(long)lth);

    if (_commandDataArr ==nil)
    {
        _commandDataArr=[NSMutableArray array];
        
    }else
    {
        [_commandDataArr removeAllObjects];
    }
    
    
    if (lth<20)
    {
        
        [commadDataThr appendData:beSeperatedData];
        NSLog(@"%@",commadDataThr);
        
        [_commandDataArr addObject:commadDataThr];
        
        
    }else if (lth>=20 && lth <= 38)
    {

        NSData *dataOne=[beSeperatedData subdataWithRange:NSMakeRange(0, 19)];
        NSData *dataTwo=[beSeperatedData subdataWithRange:NSMakeRange(19, beSeperatedData.length-19)];
        
        //第一包发过去
        [commadDataOne appendData:dataOne];
        [commadDataThr appendData:dataTwo];
        
        NSLog(@"%@",commadDataOne);
        [_commandDataArr addObject:commadDataOne];
        [_commandDataArr addObject:commadDataThr];
        
    }else
    {
        NSArray *array= [self detailedSeparated:beSeperatedData]; //-每19个一包
        
        for (NSInteger i= 0; i<array.count; i++)
        {
            
            if (i==0)
            {
                [commadDataOne appendData:array[i]];
                [_commandDataArr addObject:commadDataOne];
                
            }else if (i == array.count-1)
            {
                [commadDataThr appendData:array[i]];
                [_commandDataArr addObject:commadDataThr];
                
            }
            else
            {
                char cmd2[0];
                cmd2[0]=0x55;
                NSMutableData * commadDataTwo = [NSMutableData dataWithBytes:cmd2 length:1];
                [commadDataTwo appendData:array[i]];
                [_commandDataArr addObject:commadDataTwo];
                
            }
            
        }
        
    }
    NSLog(@"%@",_commandDataArr);
    
}

#pragma mark - NO.4 每19个一包
-(NSArray *)detailedSeparated:(NSData *)beSeperatedData
{
    NSMutableArray *dataArray=[NSMutableArray array];
    NSInteger lent=[beSeperatedData length];
    NSLog(@"%ld",lent);
    
    NSInteger elseNum=lent/19;
    NSInteger dataNum =(lent % 19 == 0)?(elseNum):(elseNum +1);
    NSLog(@"%ld",dataNum);
    
    
    for (NSInteger i=0; i<dataNum; i++)
    {
        if (i !=dataNum-1 )
        {
            NSData *data=[beSeperatedData subdataWithRange:NSMakeRange(i*19, 19)];
            NSLog(@"%ld==%@",i,data);
            [dataArray addObject:data];
            
        }else
        {
            NSData *data=[beSeperatedData subdataWithRange:NSMakeRange((dataNum -1)*19, beSeperatedData.length-(dataNum - 1)*19)];
            NSLog(@"%ld==%@",i,data);
            [dataArray addObject:data];
            
        }
    }
    
    NSLog(@"%@",dataArray);
    return dataArray;
}












- (void)cmd_response
{
    NSLog(@"%ld",arrNum);
    
    switch (cmd_tmp.status)
    {
        case CMD_SEND_CONTINUE:
        {
            // 收到响应{"ret":1}后,继续发送剩下的命令部分
            // 发送命令数据,并准备接收响应数据.
            [self prepareAndSend:++arrNum];
            
            NSLog(@"%ld",arrNum);
        }
            break;
        case CMD_SEND_LAST:
        {
            cmd_tmp.status = CMD_SEND_LAST;
            [self prepareAndSend:++arrNum];
            
        }
            break;
            
        default:
            
            break;
    }
    
}

- (char)getCharValue:(char)chr
{
    if(chr < 'A')
    {
        return (chr - '0');
    }
    else if(chr < 'a')
    {
        return (chr - 'A')+10;
    }
    else
    {
        return (chr - 'a')+10;
    }
}

- (void)sendCmd:(char*)cmd retValue:(bool)retValue
{
    //NSLog(@"--->start send!\n");
    need_value = retValue;
    cmd_tmp.status = CMD_SEND_START;
    
    arrNum=1;
    
    
    [self.mutData resetBytesInRange:NSMakeRange(0, self.mutData.length)];
    [self.mutData setLength:0];
    
    
    [self prepareAndSend:1];
    
}

#pragma mark - Pack Command

-(void)Pack_Cmd:(char) cmd
{
    
    
    identifierForBLE = cmd;
    switch(cmd)
    {
        case CMD_getFilesInfo:
        {
            [self sendCmd:nil retValue:NO];
        }
            break;
        case CMD_setWifiSSIDAndPassword:
        {
            [self sendCmd:nil retValue:NO];
        }
             break;
        case CMD_addNodeToMesh:
        {
            [self sendCmd:nil retValue:NO];
        }
            break;
        case CMD_GetNodeSNAndNodeType:
        {
            [self sendCmd:nil retValue:NO];
        }
            break;
        case CMD_setIvAndKeyForIPC:
        {
            [self sendCmd:nil retValue:NO];
        }
            break;
    }
}


-(void)start_timer:(int)timerindex timeout:(double)tmo selector:(SEL)aSelector
{
    
    if(timerindex==0)
    {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:tmo target:self selector:aSelector userInfo:nil repeats:NO];
    }
    else if(timerindex==1)
    {
        myTimer1 = [NSTimer scheduledTimerWithTimeInterval:tmo target:self selector:aSelector userInfo:nil repeats:NO];
    }
    else if(timerindex==2)
    {
        myTimer2 = [NSTimer scheduledTimerWithTimeInterval:tmo target:self selector:@selector(cmdSendTimeOutMth) userInfo:nil repeats:NO];
    }else if (timerindex == 3)
    {
        myTimer3 = [NSTimer scheduledTimerWithTimeInterval:tmo target:self selector:aSelector userInfo:nil repeats:NO];
    }
}

-(void)cmdSendTimeOutMth
{
    if ( _cmdSendTimeOut !=YES)
    {
        _cmdSendTimeOut=NO;
        [self.mutData resetBytesInRange:NSMakeRange(0, self.mutData.length)];
        [self.mutData setLength:0];
        //超时自动重发
        [self Pack_Cmd:CMD_getFilesInfo];
        
        
    }
    
    
}

#pragma mark- 写数据-----
- (void)prepareAndSend:(NSInteger)index
{
    
    [self start_timer:1 timeout:20 selector:@selector(did_send_timeout1:)];

    NSLog(@"%ld",_commandDataArr.count);
    
    if (_commandDataArr.count < index)
    {
        return;
    }
    
    switch(cmd_tmp.status)
    {
        case CMD_SEND_START:
        case CMD_SEND_CONTINUE:
        {
            if(_commandDataArr.count > index)
            {
                cmd_tmp.status = CMD_SEND_CONTINUE;
                if (_commandDataArr.count -1 == index )
                {
                    cmd_tmp.status = CMD_SEND_LAST;
                    
                }
            }else
            {
                            
                // 如果是最后一块命令数据
                cmd_tmp.status = CMD_SEND_LAST;
            }
      
            
            NSLog(@"%@",_curPeripheral);
            
            [_curPeripheral writeValue:_commandDataArr[index-1] forCharacteristic:transCharacteristics type:CBCharacteristicWriteWithResponse];
        
            
        }
            break;
            
        default:
        {
            _cmdSendTimeOut=NO;

            [_curPeripheral writeValue:_commandDataArr[index-1] forCharacteristic:transCharacteristics type:CBCharacteristicWriteWithResponse];
        }
            break;
    }
}


#pragma mark - 连接超时
- (void)did_Connect_timeout
{
    
    if (myTimer3 != nil)
    {
        [myTimer3 invalidate];
        myTimer3 = nil;
        
        if ([_BLTDelegate respondsToSelector:@selector(connectTimeOut)])
        {
            [_BLTDelegate connectTimeOut];
        }
    }
    
}


#pragma mark - 断开连接
- (void)did_disconnect_per
{
    if (myTimer != nil)
    {
        [myTimer invalidate];
        myTimer = nil;
    }
    if ([_BLTDelegate respondsToSelector:@selector(didDisconnectPeripheral)])
    {
        [_BLTDelegate didDisconnectPeripheral];
    }
   
}
- (void)didnot_find_device
{
    if (myTimer != nil)
    {
        [myTimer invalidate];
        
        myTimer = nil;
    }
    
    if ([_BLTDelegate respondsToSelector:@selector(didnotFindDevice)])
    {
        [_BLTDelegate didnotFindDevice];
    }
}



- (void)did_send_timeout1:(char)identifierForBLE1
{
    NSLog(@"myTimer1 is timeout\n");

    [myTimer1 invalidate];
    
    
    if ([_BLTDelegate respondsToSelector:@selector(searchProductInfoReceiveBagTimeOut)] && identifierForBLE1==CMD_getFilesInfo)
    {
        [_BLTDelegate searchProductInfoReceiveBagTimeOut];
    }
    
    
    if ([_wifiDelegate respondsToSelector:@selector(connectWifiTimeOut)]&& identifierForBLE1==CMD_setWifiSSIDAndPassword)
    {
        [_wifiDelegate connectWifiTimeOut];
    }
//    
//    if ([_ipcRegDelegate respondsToSelector:@selector(IpcRegTimeOut)]&& identifierForBLE1==CMD_Cloud_register)
//    {
//        [_ipcRegDelegate IpcRegTimeOut];
//    }
    
    
}








- (void)clear_timer:(int)timerindex
{
    if(timerindex == 0)
    {
        [myTimer invalidate];
        myTimer = nil;
        //NSLog(@"myTimer is cleared\n");
    }
    else if(timerindex == 1)
    {
        [myTimer1 invalidate];
        myTimer1 = nil;
        //NSLog(@"myTimer1 is cleared\n");
    }
    else if(timerindex == 2)
    {
        [myTimer2 invalidate];
        myTimer2 = nil;
        //NSLog(@"myTimer2 is cleared\n");
    }else if(timerindex == 3)
    {
        [myTimer3 invalidate];
        myTimer3 = nil;
        //NSLog(@"myTimer2 is cleared\n");
    }

    
}


#pragma mark -随机生成字符串
-(void)getRandomStr:(int )CharNum  for:(NSString *)ivOrKeyOrsignin
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
        NSData *randomIVData=[NSData dataWithBytes:cmd length:NUMBER_OF_CHARS];
        
        user.netIVData = randomIVData;
        user.netIv=dataPoint;
        NSLog(@"netIVData====%@",randomIVData);

        
    }else if ([ivOrKeyOrsignin isEqualToString:@"netKey"])
    {
        NSData *randomKEYData=[NSData dataWithBytes:cmd length:NUMBER_OF_CHARS];
        user.netKeyData = randomKEYData;
        user.netKey=dataPoint;
        NSLog(@"netKeyData====%@",randomKEYData);

    }
}


@end
