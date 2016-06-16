

//
//  ConnectWifiVC.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/26.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "ConnectWifiVC.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "HttpTools.h"
#import "getDevInfoByBLE.h"
#import "ChooseDoorKindVC.h"


@interface ConnectWifiVC ()
{
    NSInteger countNum;
}
@end

@implementation ConnectWifiVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_bl stopScanBLE];
    [_bl cleanup];
}


-(void)createUI
{
      WS(ws);
    //    图片
    UIImageView *imgView=[[UIImageView alloc]init];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image=[UIImage imageNamed:@"1.png"];
    [self.view addSubview:imgView];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.equalTo(ws.constrainView).with.offset(10);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.height.equalTo(@250);
    }];
    
    //    相机名称
    UITextField *ssidTf =[[UITextField alloc]init];
    ssidTf.placeholder=[[self currentNetworkInfo] objectForKey:@"SSID"];
    ssidTf.borderStyle=UITextBorderStyleRoundedRect;
    _ssidTf=ssidTf;
    [self.view addSubview:ssidTf];
    [ssidTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.equalTo(imgView).with.offset(70);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.width.equalTo(@60);
    }];
    
    
    UITextField *pwdTf =[[UITextField alloc]init];
    pwdTf.placeholder=@"请输入wifi密码";
    pwdTf.borderStyle=UITextBorderStyleRoundedRect;
    _pwdTf=pwdTf;
    pwdTf.delegate=self;
    [self.view addSubview:pwdTf];
    [pwdTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.constrainView.mas_centerX);
        make.top.equalTo(ssidTf).with.offset(70);
        make.left.equalTo(ws.constrainView).with.offset(10);
        make.right.equalTo(ws.constrainView).with.offset(-10);
        make.width.equalTo(@60);
        
    }];
    
    UIButton *conWifiBtn=[[UIButton alloc]init];
    [self.view addSubview:conWifiBtn];
    [conWifiBtn setTitle:@"连接WIFI" forState:UIControlStateNormal];
    [conWifiBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    conWifiBtn.backgroundColor=[UIColor redColor];
    [conWifiBtn addTarget:self action:@selector(connecWifi) forControlEvents:UIControlEventTouchUpInside];
    _conWifiBtn=conWifiBtn;
[conWifiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(ws.constrainView.mas_centerX);
    make.top.equalTo(pwdTf).with.offset(70);
    make.left.equalTo(ws.constrainView).with.offset(10);
    make.right.equalTo(ws.constrainView).with.offset(-10);
    make.width.equalTo(@60);
    
}];
    
}


-(void)connecWifi
{
    _conWifiBtn.enabled=NO;
    _conWifiBtn.backgroundColor=[UIColor grayColor];
    
        _BSh=[[BusyShowView alloc]init];
        [self.view addSubview:[_BSh createBusyShow:self.view]];
        [_BSh startAnima];
       [MBProgressHUD showError:@"正在发送wifi信息给IPC" toView:self.view];
    
    _loadingTimer=[NSTimer timerWithTimeInterval:60 target:self selector:@selector(stopLoading) userInfo:nil repeats:YES];

    
    //调用BlueToothAPI里面封装的方法，连接wifi
    _bl=[BlueToothAPI shareInstan];
    _bl.wifiDelegate=self;
    
    _bl.ssidStr=_ssidTf.text;
    _bl.wifiPwd=_pwdTf.text;
    
    _ssidTf.enabled=NO;
    
    [_bl ConnectWIFI];
    [_bl Pack_Cmd:CMD_setWifiSSIDAndPassword];
    
    //IPC just receive ssid and pwd
    _bl.wifiConBlock=^(BOOL _isCon){
        
        User *user=[User sharedUser];
        
        if (_isCon && [user.addDeviceOrSetWifi isEqualToString:@"ADDDEV"])
        {
           //查询是否被其他人关联
            NSLog(@"查询是否被其他人关联");
            [MBProgressHUD showError:@"查询是否被其他人关联" toView:self.view];
            
            [self isConnetByOther];
            
        }else if (_isCon && [user.addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
        {
            [self   afterSetWifiLinkedTocloud];
        }
    };
}


-(void)stopLoading
{
    [_BSh stopAnima];
}

#pragma mark- 获取该设备连接的wifi
-(id)currentNetworkInfo
{
    NSArray * ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString * ifname in ifs)
    {
        info = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname));
        if(info && [(NSDictionary *)info count])
        {
            break;
        }
    }
    return info;
}

#pragma mark -查询是否连上云端
-(void)afterSetWifiLinkedTocloud
{
    getDevInfoByBLE *getInfo=[getDevInfoByBLE shareInstanc];
    User *user=[User sharedUser];
    
    [HttpTools IPCConnectCloudSn:getInfo.bleGetSN block:^(BOOL successOrNot) {
        
        
        if (successOrNot)
        {
//            如果连上云端
            if ([user.addDeviceOrSetWifi isEqualToString:@"ADDDEV"])
            {
                
                [self RelateTheIpc];
            }else if ([user.addDeviceOrSetWifi isEqualToString:@"SETWIFI"])
            {
                
                
            }
  
        }
        else
        {
            //每隔十秒中查询一次，查询五次
            NSLog(@"%ld",countNum);
            if (countNum == 5)
            {
                countNum = 0;
                if (_timer)
                {
                    [_timer invalidate];
                    _timer = nil;
                }
                [MBProgressHUD showError:@"IPC设备没有连接上云端" toView:self.view];
                
            }else
            {
                
                countNum ++;
                NSLog(@"===multi**************=%ld=",countNum);
                [self regularlySendTocheck];
            }
        }

        
        
    } errorIn:^(NSError *error) {
        
    }];
  
}

#pragma mark - 查询是否被其他人关联
-(void)isConnetByOther
{
    //首先查询设备是否关联，如果已经关联的话就不用注册-关联了，否则就往下进行
    //查询设备是否被其他人关联
    //0 没有被关联
    //1 被自己关联
    //2 被其它人关联
      getDevInfoByBLE *getInfo=[getDevInfoByBLE shareInstanc];
     [MBProgressHUD showError:@"正在查询是否被其他人关联" toView:self.view];
    
    [HttpTools orNotTobeLinkedSn:getInfo.bleGetSN block:^(NSDictionary *dic) {
        NSString * isOwnedByOther= dic[@"ownedByOther"][@"isOwnedByOther"][@"text"];
        
        
//        设置IPC的NetIv 和 NetKey
        [_bl setNetIvandNetKeyForIPC:0];
        
        [_bl Pack_Cmd:CMD_setIvAndKeyForIPC];
        
        //写入数据到plist文件
        NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[User sharedUser].netIv,@"netIv",[User sharedUser].netKey,@"netKey",nil];
        //将上面2个小字典保存到大字典里面
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        [dataDic setObject:dic1 forKey:getInfo.bleGetSN];
        //写入plist里面
        NSLog(@"%@",FILEPATH);
        [dataDic writeToFile:FILEPATH atomically:YES];
        
        //读取plist文件的内容
        NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:FILEPATH];
        NSLog(@"---设置完wifi后，写入plist后，读到的plist文件的内容---%@",dataDictionary);
        
        if ([isOwnedByOther isEqualToString:@"0"])
        {
            
            //写入数据到plist文件
            NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[User sharedUser].netIv,@"netIv",[User sharedUser].netKey,@"netKey",nil];
            //将上面2个小字典保存到大字典里面
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            [dataDic setObject:dic1 forKey:getInfo.bleGetSN];
            //写入plist里面
            [dataDic writeToFile:FILEPATH atomically:YES];
            
            
            
            [MBProgressHUD showError:@"没有被其他人关联" toView:self.view];
            
            //查询是否连上云端
            [self afterSetWifiLinkedTocloud];
        }else if ([isOwnedByOther isEqualToString:@"1"])
        {
            [MBProgressHUD showError:@"您已经关联该设备" toView:self.view];
            NSLog(@"您已经关联该设备");
            [_BSh stopAnima];
            [self.navigationController popToRootViewControllerAnimated:YES];

         }else if ([isOwnedByOther isEqualToString:@"2"])
        {
            [MBProgressHUD showError:@"设备已经被其他人关联，跳转到解除关联页面" toView:self.view];
            [_BSh stopAnima];
            NSLog(@"设备已经被其他人关联，跳转到解除关联页面");
            [self.navigationController popToRootViewControllerAnimated:YES];

        }
    } errorIn:^(NSError *error) {
         [_BSh stopAnima];
    }];
}






-(void)regularlySendTocheck
{
    [self performSelectorInBackground:@selector(multiThreadTocheck) withObject:nil];
}

-(void)multiThreadTocheck
{
    NSLog(@"===multiThread=%ld==",countNum);
    if (_timer && [_timer isValid])
    {
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(timerActionTocheck) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

-(void)timerActionTocheck
{
    [self afterSetWifiLinkedTocloud];
}


#pragma mark - 关联设备
-(void)RelateTheIpc
{
    NSLog(@"开始关联设备……");
 
    //设备关联
    
    [HttpTools requestToRelateblock:^(BOOL successOrNot) {
        
        if (successOrNot == YES)
        {
//            跳转到选择one door Or two door页面
            [_BSh stopAnima];
            ChooseDoorKindVC *cvc=[[ChooseDoorKindVC alloc]init];
            [self.navigationController pushViewController:cvc animated:YES];
        }else
        {
            [MBProgressHUD showError:@"关联设备失败" toView:self.view];
        }
    } errorIn:^(NSError *error) {

    }];
}



//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_ssidTf resignFirstResponder];
    [_pwdTf resignFirstResponder];
}
@end
