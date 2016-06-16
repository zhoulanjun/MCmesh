//
//  NodeSingleCell.m
//  MCmesh
//
//  Created by zhoulanjun on 16/6/16.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "NodeSingleCell.h"

@implementation NodeSingleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

-(void)initSubViews
{
    WS(ws);
    
    //            图片
    _nodeImgView=[[UIImageView alloc]init];
    _nodeImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView  addSubview:_nodeImgView];
    [_nodeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.contentView.mas_top).with.offset(10);
        make.left.equalTo(ws.contentView.mas_left).with.offset(5);
    }];

    _nodeNameLabel= [[UILabel alloc]init];
    _nodeNameLabel.textColor=[UIColor blackColor];
    _nodeNameLabel.font=[UIFont systemFontOfSize:19 weight:9];
    _nodeNameLabel.textAlignment=NSTextAlignmentCenter;
    [self.contentView  addSubview:_nodeNameLabel];
    [_nodeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.contentView.mas_top).with.offset(5);
        make.left.equalTo(_nodeImgView.mas_right).with.offset(10);
        make.width.mas_equalTo(@80);
        make.height.mas_equalTo(@40);
    }];
    
    //            图片
    _tickImgView=[[UIImageView alloc]init];
    _tickImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView  addSubview:_tickImgView];
    [_tickImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.contentView.mas_top).with.offset(10);
        make.right.equalTo(ws.contentView.mas_right).with.offset(-30);
    }];
    _tickImgView.userInteractionEnabled=YES;
    
    //添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tickImgStatusChange)];
    [_tickImgView addGestureRecognizer:tap];
    
    
    
    
    _addDevBtn=[[UIButton alloc]init];
    [self.contentView  addSubview:_addDevBtn];
    [_addDevBtn setTitle:@"Add Device" forState:UIControlStateNormal];
    [_addDevBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    _addDevBtn.backgroundColor=[UIColor redColor];
    [self.addDevBtn addTarget:self action:@selector(bleSnTypeIvKeyAction) forControlEvents:UIControlEventTouchUpInside];
    [_addDevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.contentView.mas_bottom).with.offset(10);
        make.left.equalTo(ws.contentView.mas_left).with.offset(0);
        make.width.mas_equalTo(@130);
        make.height.mas_equalTo(@40);
    }];
}


-(void)bleSnTypeIvKeyAction
{


}


#pragma mark -重写该方法来使cell中间有间隔
-(void)setFrame:(CGRect)frame
{
    frame.origin.y += 10;
    frame.size.height-=10;
    frame.size.width-=10;
    frame.origin.x +=5;
    [super setFrame:frame];
}

#pragma mark -点击事件
-(void)tickImgStatusChange
{
    _tickImgView.image=[UIImage imageNamed:_selOrNot?@"tick":@"nottick"];
    _selOrNot=!_selOrNot;
}



@end
