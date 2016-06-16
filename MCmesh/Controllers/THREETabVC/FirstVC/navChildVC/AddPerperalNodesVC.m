//
//  AddPerperalNodesVC.m
//  MCmesh
//
//  Created by zhoulanjun on 16/6/16.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "AddPerperalNodesVC.h"
#import "HttpTools.h"
#import "IpcModel.h"
#import "getDevInfoByBLE.h"
#import "NodeModel.h"
#import "NodeSingleCell.h"

@interface AddPerperalNodesVC ()

@end

@implementation AddPerperalNodesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    User *user=[User sharedUser];
    user.addDeviceOrSetWifi=@"CONCERNODE";
    self.navigationItem.title=@"New Device";
    _blueTthManager=[BlueToothAPI shareInstan];

    
    WS(ws);
    UITableView *tbv=[[UITableView alloc]init];
    [self.view  addSubview:tbv];
    _tbv=tbv;
    tbv.delegate=self;
    tbv.separatorStyle=UITableViewCellSeparatorStyleNone;
    tbv.backgroundColor=APPBACKCOLOR;

    
    tbv.dataSource = self;    
    [tbv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.view.mas_centerX);
        make.top.equalTo(ws.constrainView.mas_top).with.offset(0);
        make.left.equalTo(ws.view.mas_left).with.offset(0);
        make.right.equalTo(ws.view.mas_right).with.offset(0);
        make.bottom.equalTo(ws.view.mas_bottom).with.offset(0);
    }];
    
    _blueTthManager.BLTDelegate=self;

    [self getNodeSnAndType];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_blueTthManager stopScanBLE];

    [_blueTthManager cleanup];
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
                    //设置节点的IV 和 Key
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

-(void)BluetoothFoundNodes
{
    [MBProgressHUD showError:@"已经找到Mesh节点，正在连接" toView:self.view];
// 把节点一个一个呈现在cell上：
  
// [_blueTthManager connect:findedNodePer];
    
    
    [_tbv reloadData];
    
}




//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_NodeNameText resignFirstResponder];
}

#pragma mark -delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_blueTthManager.PeriNodeModels count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NodeCell = @"NodeCell";
    NodeSingleCell *cell =[tableView dequeueReusableCellWithIdentifier:NodeCell];
    NodeModel *node =_blueTthManager.PeriNodeModels[indexPath.row];
    if (cell == nil)
    {
        cell=[[NodeSingleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NodeCell];
    }
    
    cell.nodeImgView.image=[UIImage imageNamed:node.peripheralName];
    cell.nodeNameLabel.text=node.peripheralName;
    cell.tickImgView.image=[UIImage imageNamed:@"tick"];
    return cell;
}



@end
