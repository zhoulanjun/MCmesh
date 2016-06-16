//
//  MeshNodeInfoVC.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/30.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothAPI.h"
#import "BusyShowView.h"


@interface MeshNodeInfoVC : BaseViewController<BlueToothAPIDelegate>
@property (nonatomic,retain)NSString *IPCSN;
//对应的是tableviewcell的第几个元素 也就是数组的第几个元素
@property (nonatomic,assign)NSInteger locIndex;
@property (nonatomic,strong)BlueToothAPI *blueTthManager;

//IPC 的信息展示框
@property (nonatomic,retain)UITextView *txv;
//添加节点的button
@property (nonatomic,retain)UIButton *addNodebtn;
//开关灯的按钮
@property (nonatomic,retain)UIButton *LightBtn;
//节点名字输入框
@property (nonatomic,retain)  UITextField *NodeNameText;
//删除Mesh节点按钮
@property (nonatomic,retain) UIButton *deleteNodebtn;


@end
