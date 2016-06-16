//
//  AddDeviceVC.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/25.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "AddDeviceVC.h"
#import "ConnectWifiVC.h"

@interface AddDeviceVC ()

@end

@implementation AddDeviceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self recreatUI];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _blueTthManager.BLTDelegate=self;
}

-(void)recreatUI
{
    [MBProgressHUD showError:[NSString stringWithFormat:@"Please turn on  Bluetooth and wifi "] toView:self.view];
    
    _blueTthManager=[BlueToothAPI shareInstan];
    
    
    User *user=[User sharedUser];
    
    if ([user.addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
    {
        self.navigationItem.title=@"Set Wifi";
    }else
    {
        self.navigationItem.title=@"Add Camera";
    }
    
    UIButton *scanFilterBtn=[[UIButton alloc]initWithFrame:CGRectMake(30, 250, 250, 40)];
    [self.view addSubview:scanFilterBtn];
    scanFilterBtn.center=CGPointMake(VIEWWIDTH/2,250);
    [scanFilterBtn setTitle:@"开始过滤扫描我公司设备" forState:UIControlStateNormal];
    scanFilterBtn.backgroundColor=BTNBACKCOLOR;
    scanFilterBtn.titleLabel.textColor = BTNTXTCOLOR;
    scanFilterBtn.layer.cornerRadius=5;
    [scanFilterBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    [scanFilterBtn addTarget:self action:@selector(scanFilterAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -过滤扫描我公司设备
-(void)scanFilterAction
{
    if (_blueTthManager.bleIsOpen)
    {
//        [_blueTthManager.Peripherals removeAllObjects];
        [self beginScanPeripheral];
    }
}

//确认蓝牙是打开状态后，开始扫描
-(void)beginScanPeripheral
{
    [MBProgressHUD showError:@"已开始过滤扫描我公司设备" toView:self.view];
    //开始扫描周边
    [_blueTthManager startScan];
}

#pragma BlueToothAPIDelegate
-(void)BluetoothFound:(CBPeripheral *)findedPer
{
    [MBProgressHUD showError:@"已经找到IPC设备，正在连接" toView:self.view];
    //找到设备就开始连接
    NSLog(@"已经找到IPC设备，正在连接%@",findedPer);
    
    if (findedPer)
    {
        [_blueTthManager connect:findedPer];
    }
    __weak typeof(self) weakself = self;
    
    _blueTthManager.isLegal =^(BOOL _isLegal){
        
        if (weakself.BSh)
        {
            [weakself.BSh stopAnima];
        }
        
        if (_isLegal)
        {
            ConnectWifiVC *wifiVc= [[ConnectWifiVC alloc]init];
            [weakself.navigationController pushViewController:wifiVc animated:YES];
            
        }else
        {
            NSLog(@"===很抱歉,IPC注册失败==");
            User *user=[User sharedUser];
            if ([user.addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
            {
                [MBProgressHUD showError:@"请关闭其他设备的蓝牙" toView:weakself.view];
            }else
            {
                [MBProgressHUD showError:@"IPC注册失败，验证SN失败" toView:weakself.view];
            }
        }
    };
}





@end
