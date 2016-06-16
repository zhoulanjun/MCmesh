//
//  PrepareStartVc.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/30.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "PrepareStartVc.h"
//#import "AddDeviceVC.h"

#import "ConnectWifiVC.h"

@interface PrepareStartVc ()

@end

@implementation PrepareStartVc

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _blueTthManager.BLTDelegate=self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _blueTthManager=[BlueToothAPI shareInstan];

    self.navigationItem.title=@"PREPARE";
    
    WS(ws);

    UILabel *textLb=[UILabel new];
    textLb.text=@"Get Ready to Install";
    textLb.textAlignment=NSTextAlignmentCenter;
    textLb.font=[UIFont systemFontOfSize:30];
    textLb.backgroundColor=[UIColor redColor];
    [self.view addSubview:textLb];
    [textLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.mas_equalTo(ws.constrainView).with.offset(60);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];

    
    
    UITextView *txv =[[UITextView alloc]init];
    txv.font=[UIFont systemFontOfSize:25];
    txv.text=[NSString stringWithFormat:@"1.please connect your device and turn power on\n2.Walk close to your device\n3.Turn on your mobile Bluetooth\n4.Connect WIFI from your mobile"];
    [self.view addSubview:txv];
    [txv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.equalTo(textLb).with.offset(60);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@250);
    }];
    
    UIButton *preStartBtn=[[UIButton alloc]init];
    [self.view addSubview:preStartBtn];
    preStartBtn.layer.cornerRadius=5;
    preStartBtn.titleLabel.textColor = BTNTXTCOLOR;
    preStartBtn.backgroundColor=BTNBACKCOLOR;
    [preStartBtn setTitle:@"Start" forState:UIControlStateNormal];
    [preStartBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    [preStartBtn addTarget:self action:@selector(goOnAddDevice) forControlEvents:UIControlEventTouchUpInside];
    [preStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.bottom.equalTo(ws.constrainView).with.offset(-50);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];
}


-(void)goOnAddDevice
{
//    判断蓝牙 WIFI是否开启
    
    NSLog(@"app用户使用的网络为：%@",[User sharedUser].useNetType);
    
    if ([[User sharedUser].useNetType isEqualToString:@"ReachableViaWiFi"])
    {
        [self scanFilterAction];
//        [_BSh startAnima];
    }else
    {
        [MBProgressHUD showError:@"Please Turen on bluetooth and connect wifi，Press here go to settings." toView:self.view];

    }

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
