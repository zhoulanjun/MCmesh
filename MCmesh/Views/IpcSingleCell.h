//
//  IpcSingleCell.h
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IpcSingleCell : UITableViewCell
@property (nonatomic,retain)UIImageView *  imgView;
@property (nonatomic,retain)UILabel *  IPCNameLabel;
@property (nonatomic,retain)UILabel *  IPCKindLabel;


@property (nonatomic,retain)NSString *  IPCSN;
@property (nonatomic,assign)NSInteger  locIndex;


@property (nonatomic,strong)UIButton *createMeshNetBtn;
@property (nonatomic,strong)UIButton *deleteMeshNetBtn;
@property (nonatomic,strong)UIButton *unLinkDeviceBtn;
@property (nonatomic,strong)UIButton *addNodesBtn;

@end
