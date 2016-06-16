//
//  ConnectWifiVC.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/26.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothAPI.h"
#import "BusyShowView.h"

@interface ConnectWifiVC : BaseViewController<ConnectWifiDelegate>
@property (nonatomic,weak)BlueToothAPI *bl;
@property (nonatomic,retain)UITextField *ssidTf;
@property (nonatomic,retain)UITextField *pwdTf;
@property (nonatomic,retain)UIButton *conWifiBtn;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)NSTimer *loadingTimer;
@property (nonatomic,retain)BusyShowView *BSh;
@end
