//
//  PrepareStartVc.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/30.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothAPI.h"
#import "BusyShowView.h"


@interface PrepareStartVc : BaseViewController<BlueToothAPIDelegate>

//暂时保留
@property (nonatomic,strong)BlueToothAPI *blueTthManager;
@property (nonatomic,strong)BusyShowView *BSh;

@end
