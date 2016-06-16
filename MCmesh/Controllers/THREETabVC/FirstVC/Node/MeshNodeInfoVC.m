
//
//  MeshNodeInfoVC.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/30.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "MeshNodeInfoVC.h"
#import "HttpTools.h"
#import "IpcModel.h"
#import "getDevInfoByBLE.h"

@interface MeshNodeInfoVC ()

@end

@implementation MeshNodeInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self recreateUI];
    
    
 }


-(void)recreateUI
{
    self.navigationItem.title=@"蓝牙连接指定设备";
    
    
    User *user=[User sharedUser];
    user.addDeviceOrSetWifi=@"CONCERNODE";
    WS(ws);
    
    UITextView *txv =[[UITextView alloc]init];
    txv.backgroundColor=[UIColor grayColor];
    _txv=txv;
    _txv.font=[UIFont systemFontOfSize:20];
    _txv.textColor=[UIColor yellowColor];
    [self.view addSubview:txv];
    [txv mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(ws.constrainView.mas_centerX);
                make.top.mas_equalTo(ws.constrainView.mas_top).with.offset(20);
                make.left.equalTo(ws.constrainView).with.offset(10);
                make.right.equalTo(ws.constrainView).with.offset(-10);
                make.height.mas_equalTo(@150);
    }];
    
    
    UIButton *preStartBtn=[[UIButton alloc]init];
    [self.view addSubview:preStartBtn];
    [preStartBtn setTitle:@"step1:查询Node节点的SN和TYPE" forState:UIControlStateNormal];
    [preStartBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    preStartBtn.backgroundColor=[UIColor redColor];
    [preStartBtn addTarget:self action:@selector(getNodeSnAndType) forControlEvents:UIControlEventTouchUpInside];
    [preStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.mas_equalTo(txv.mas_bottom).with.offset(10);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];
    
    
    UITextField *NodeNameText =[[UITextField alloc]init];
    NodeNameText.delegate=self;
    NodeNameText.placeholder=@"step2:请为该节点命名";
    NodeNameText.borderStyle=UITextBorderStyleRoundedRect;
    NodeNameText.keyboardType=UIKeyboardTypeDefault;
    _NodeNameText=NodeNameText;
    [self.view addSubview:NodeNameText];
[NodeNameText mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(ws.constrainView.mas_centerX);
    make.top.mas_equalTo(preStartBtn.mas_bottom).with.offset(10);
    make.left.equalTo(ws.constrainView).with.offset(10);
    make.right.equalTo(ws.constrainView).with.offset(-10);
    make.height.mas_equalTo(@40);
}];


    
    
    UIButton *addNodebtn=[[UIButton alloc]init];
    [self.view addSubview:addNodebtn];
    [addNodebtn setTitle:@"step3:添加节点到Mesh网络" forState:UIControlStateNormal];
    [addNodebtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    addNodebtn.backgroundColor=[UIColor grayColor];
    addNodebtn.enabled=NO;
    _addNodebtn=addNodebtn;
    [addNodebtn addTarget:self action:@selector(addNodeToMeshNet) forControlEvents:UIControlEventTouchUpInside];
    
    [addNodebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.mas_equalTo(NodeNameText.mas_bottom).with.offset(10);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];
    
                          
 
    UIButton *LightBtn=[[UIButton alloc]init];
    [self.view addSubview:LightBtn];
    [LightBtn setTitle:@"step4:开关灯按钮" forState:UIControlStateNormal];
    [LightBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    LightBtn.backgroundColor=[UIColor grayColor];
    LightBtn.enabled=NO;
    _LightBtn=LightBtn;
    [LightBtn addTarget:self action:@selector(lightOnOffBtn) forControlEvents:UIControlEventTouchUpInside];
    [LightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.mas_equalTo(addNodebtn.mas_bottom).with.offset(10);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];
    
    
    UIButton *deleteNodebtn=[[UIButton alloc]init];
    [self.view addSubview:deleteNodebtn];
    [deleteNodebtn setTitle:@"step5:删除Mesh节点（test）" forState:UIControlStateNormal];
    [deleteNodebtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    deleteNodebtn.backgroundColor=[UIColor grayColor];
    deleteNodebtn.enabled=NO;
        _deleteNodebtn=deleteNodebtn;
    [deleteNodebtn addTarget:self action:@selector(deleteNodeToMeshNet) forControlEvents:UIControlEventTouchUpInside];
    
    [deleteNodebtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.mas_equalTo(LightBtn.mas_bottom).with.offset(10);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];
    
  
    
    //    扫描连接Node 发送NetIv 和 NetKey过去
    _blueTthManager=[BlueToothAPI shareInstan];
    
    
    //    异步  把 “请求获取Mesh信息” 呈现在界面上
    [HttpTools  requestMeshInfoWithSn:self.IPCSN block:^(NSDictionary *dic) {
        
        IpcModel *iModel=[User sharedUser].deviceArr[_locIndex];
        NSLog(@"请求获取Mesh信息   %@",dic);
        iModel.netIv=dic[@"meshInfo"][@"netIv"][@"text"];
        iModel.netKey=dic[@"meshInfo"][@"netKey"][@"text"];
        iModel.netName=dic[@"meshInfo"][@"netName"][@"text"];
        NSString *showStr=[NSString stringWithFormat:@"IPC-netIv:%@;\nIPC-netKey:%@;\nIPC-netName:%@;\n",iModel.netIv,iModel.netKey,iModel.netName];
        dispatch_async(dispatch_get_main_queue(), ^{
            _txv.text=showStr;
        });
        
    } errorIn:^(NSError *error) {
        
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _blueTthManager.BLTDelegate=self;
}

-(void)getNodeSnAndType
{
    if (_blueTthManager.bleIsOpen)
    {
        [self beginScanPeripheral];
    }
    
    __weak typeof(self) weakself = self;
    
    
    _blueTthManager.getNodeSnTypeOk=^(BOOL _getSnType){
        if (_getSnType)
        {
             [MBProgressHUD showError:@"获取节点的Sn和Type成功" toView:weakself.view];
            NSLog(@"Set Node节点的 Iv和 Key");
            
            //
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
           NSString  * NodeID =[defaults valueForKey:@"NODEID"];
            
            
            //读取plist文件的内容
            NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:FILEPATH];
            NSLog(@"------%@",dataDictionary);
            NSMutableDictionary *IPCDic=dataDictionary[weakself.IPCSN];
            getDevInfoByBLE *getInfo = [getDevInfoByBLE shareInstanc];
            
            if (!IPCDic[getInfo.nodeSn])
            {
                NSInteger nodeId=[NodeID integerValue];
                ++nodeId;
                NSString *NewNodeId =[NSString stringWithFormat:@"%ld",nodeId];
                [IPCDic setObject:NewNodeId forKey:getInfo.nodeSn];
                [defaults setValue:NewNodeId forKey:@"NODEID"];
                [defaults synchronize];
                [dataDictionary writeToFile:FILEPATH atomically:YES];

            }
            NSLog(@"-----dataDictionary-%@----IPCDic--%@---%ld",dataDictionary,IPCDic,[IPCDic[getInfo.nodeSn] integerValue]);

            
            
            [weakself.blueTthManager setNetIvandNetKey:[IPCDic[getInfo.nodeSn] integerValue]];
            [weakself.blueTthManager Pack_Cmd:CMD_addNodeToMesh];
            weakself.blueTthManager.setIvKeyBlcok=^(BOOL isSetIvKey){
            
                if (isSetIvKey)
                {
                    //查询Node节点的SN 和 Type
                        weakself.addNodebtn.backgroundColor=[UIColor redColor];
                        weakself.addNodebtn.enabled=YES;
                    [MBProgressHUD showError:@"设置节点的IV 和 Key 成功" toView:weakself.view];
                    [weakself.blueTthManager cleanup];
                }

            };
            
        }
    
    };

}

-(void)addNodeToMeshNet
{
    //请求添加节点到Mesh网络
    NSLog(@"请求添加节点到Mesh网络");
    [HttpTools addMeshNode:_NodeNameText.text  ForIndex:_locIndex WithSn:self.IPCSN block:^(NSDictionary *dic) {
          NSLog(@"请求添加节点到Mesh网络  %@",dic);
        
        NSLog(@"增加mesh节点 返回信息%@",dic);
        NSString *statusCode=dic[@"appAddNode"][@"ResponseStatus"][@"statusCode"][@"text"];
        NSString *statusString=dic[@"appAddNode"][@"ResponseStatus"][@"statusString"][@"text"];
        
#warning statusCode statusString
        if ([statusCode isEqualToString:@"0"] && [statusString isEqualToString:@"Operate success"])
        {
            [MBProgressHUD showError:@"添加节点成功" toView:self.view];
            _LightBtn.enabled=YES;
            _deleteNodebtn.enabled=YES;
            _LightBtn.backgroundColor=[UIColor redColor];
            _deleteNodebtn.backgroundColor=[UIColor redColor];
        }

    } errorIn:^(NSError *error) {
        
        
    }];
}


-(void)lightOnOffBtn
{
    

}

-(void)deleteNodeToMeshNet
{
//            nodeSn
//        [HttpTools deleteMeshNodeIpcSn:_IPCSN nodeSn:<#(NSString *)#> block:^(BOOL successOrNot) {
//            
//        } errorIn:^(NSError *error) {
//            
//            
//        }];
}



//确认蓝牙是打开状态后，开始扫描
-(void)beginScanPeripheral
{
    [MBProgressHUD showError:@"蓝牙扫描该设备" toView:self.view];
    //开始扫描周边
    [_blueTthManager startScan];
}

-(void)BluetoothFoundSingleNode:(CBPeripheral *)findedNodePer
{
    [MBProgressHUD showError:@"已经找到Mesh节点，正在连接" toView:self.view];
    //找到设备就开始连接
    NSLog(@"已经找到Mesh节点，正在连接%@",findedNodePer);
    if (findedNodePer)
    {
        [_blueTthManager connect:findedNodePer];
    }
}




//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_NodeNameText resignFirstResponder];
}


@end