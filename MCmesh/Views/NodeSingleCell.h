//
//  NodeSingleCell.h
//  MCmesh
//
//  Created by zhoulanjun on 16/6/16.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeSingleCell : UITableViewCell

//节点的图片
@property (nonatomic,retain)UIImageView *nodeImgView;
@property (nonatomic,retain)UILabel *nodeNameLabel;
//☑️图片
@property (nonatomic,retain)UIImageView *tickImgView;
@property (nonatomic,assign)BOOL selOrNot;

//添加设备的按钮
@property (nonatomic,retain)UIButton *addDevBtn;

@end
