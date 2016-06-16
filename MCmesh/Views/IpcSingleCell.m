//
//  IpcSingleCell.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/13.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

#define CELLWIDTH    self.frame.size.width
#define CELLHEIGHT   self.frame.size.height

#import "IpcSingleCell.h"
#import <QuartzCore/QuartzCore.h>
#import "HttpTools.h"


@implementation IpcSingleCell

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
    _imgView=[[UIImageView alloc]init];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.image=[UIImage imageNamed:@"1.png"];
    [self.contentView  addSubview:_imgView];
[_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(ws.contentView.mas_centerX);
    make.top.mas_equalTo(ws.contentView.mas_top).with.offset(0);
    make.left.equalTo(ws.contentView.mas_left).with.offset(0);
    make.right.equalTo(ws.contentView.mas_right).with.offset(0);
    make.bottom.equalTo(ws.contentView.mas_bottom).with.offset(0);
}];
    
    
    
    _IPCNameLabel= [[UILabel alloc]init];
    _IPCNameLabel.backgroundColor=[UIColor yellowColor];
    _IPCNameLabel.textColor=[UIColor blackColor];
    _IPCNameLabel.font=[UIFont systemFontOfSize:19 weight:9];
    _IPCNameLabel.textAlignment=NSTextAlignmentCenter;
    [self.contentView  addSubview:_IPCNameLabel];
    [_IPCNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.contentView.mas_top).with.offset(0);
        make.left.equalTo(ws.contentView.mas_left).with.offset(0);
        make.width.mas_equalTo(@130);
        make.height.mas_equalTo(@40);
        
    }];
    
    _IPCKindLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_IPCKindLabel];
    _IPCKindLabel.textColor=[UIColor blackColor];
    _IPCKindLabel.backgroundColor=[UIColor yellowColor];
    _IPCKindLabel.font=[UIFont systemFontOfSize:19 weight:9];
    _IPCKindLabel.textAlignment=NSTextAlignmentCenter;
    [self.contentView  addSubview:_IPCKindLabel];
    [_IPCKindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_IPCNameLabel.mas_bottom).with.offset(10);
        make.left.equalTo(ws.contentView.mas_left).with.offset(0);
        make.width.mas_equalTo(@130);
        make.height.mas_equalTo(@40);
    }];

        //    相机类型
    _createMeshNetBtn=[[UIButton alloc]init];
    [self.contentView  addSubview:_createMeshNetBtn];
    [_createMeshNetBtn setTitle:@"1  创建网络" forState:UIControlStateNormal];
    [_createMeshNetBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    _createMeshNetBtn.backgroundColor=[UIColor redColor];
    [self.createMeshNetBtn addTarget:self action:@selector(createNetMeshAction) forControlEvents:UIControlEventTouchUpInside];
    [_createMeshNetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(_IPCKindLabel.mas_bottom).with.offset(10);
        make.left.equalTo(ws.contentView.mas_left).with.offset(0);
        make.width.mas_equalTo(@130);
        make.height.mas_equalTo(@40);
    }];
    
    
    _deleteMeshNetBtn=[[UIButton alloc]init];
    [self.contentView  addSubview:_deleteMeshNetBtn];
    [_deleteMeshNetBtn setTitle:@"删除网络" forState:UIControlStateNormal];
    [_deleteMeshNetBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    _deleteMeshNetBtn.backgroundColor=[UIColor redColor];
    [self.deleteMeshNetBtn addTarget:self action:@selector(deleteNetMeshAction) forControlEvents:UIControlEventTouchUpInside];
    [_deleteMeshNetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_createMeshNetBtn.mas_bottom).with.offset(10);
        make.left.equalTo(ws.contentView.mas_left).with.offset(0);
        make.width.mas_equalTo(@130);
        make.height.mas_equalTo(@40);
    }];
    
    //解除关联设备
    _unLinkDeviceBtn=[[UIButton alloc]init];
    [self.contentView  addSubview:_unLinkDeviceBtn];
    [_unLinkDeviceBtn setTitle:@" 解除关联该设备" forState:UIControlStateNormal];
    [_unLinkDeviceBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    _unLinkDeviceBtn.backgroundColor=[UIColor redColor];
    [self.unLinkDeviceBtn addTarget:self action:@selector(unlinkThisDevice) forControlEvents:UIControlEventTouchUpInside];
    [_unLinkDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_deleteMeshNetBtn.mas_right).with.offset(30);
        make.bottom.equalTo(ws.contentView.mas_bottom).with.offset(-10);
        make.width.mas_equalTo(@130);
        make.height.mas_equalTo(@40);
    }];
    
       //解除关联设备
    _unLinkDeviceBtn=[[UIButton alloc]initWithFrame:CGRectMake(260, 160, 180, 40)];
   

        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [[UIColor greenColor] CGColor];
}

/*
 如果在自定义单元格中，修改默认对象的位置
 
 可以重写layoutSubviews方法，对视图中的所有控件的位置进行调整
 */
#pragma mark - 重新调整UITalbleViewCell中的控件布局
- (void)layoutSubviews
{


}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];
    
    // 选中表格行
    if (selected)
    {
        [self setBackgroundColor:[UIColor purpleColor]];
    } else
    {
        // 撤销选中表格行
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)createNetMeshAction
{
    NSLog(@"创建网络SN:%@……%@",self.IPCSN,self.IPCNameLabel.text);
    [HttpTools createMeshNetFor:_locIndex WithSN:self.IPCSN WithName:self.IPCNameLabel.text block:^(BOOL successOrNot) {
        
        if (successOrNot) {
         [MBProgressHUD showSuccess:@"Yes" toView:self.window];
     }else{
         [MBProgressHUD showError:@"No" toView:self.window];
     }
    } errorIn:^(NSError *error) {
        [MBProgressHUD showError:@"No" toView:self.window];
    }];
}


-(void)deleteNetMeshAction
{
    NSLog(@"删除网络SN:%@……",self.IPCSN);
    [HttpTools deleteMeshNetWithSn:self.IPCSN block:^(BOOL successOrNot) {
        
        if (successOrNot)
        {
            [MBProgressHUD showSuccess:@"Yes" toView:self.window];
        }else
        {
            [MBProgressHUD showError:@"No" toView:self.window];
        }
    } errorIn:^(NSError *error) {
        [MBProgressHUD showError:@"No" toView:self.window];
    }];
}

-(void)unlinkThisDevice
{
    [HttpTools unlinkDeviceWithSn:self.IPCSN block:^(BOOL successOrNot) {
        
        if (successOrNot)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SUCCESSUNLINKDEVICE" object:nil];
            
            NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:FILEPATH];
            [dataDictionary removeAllObjects];
            NSLog(@"解除关联设备后，plist文件的内容为：%@",dataDictionary);
            
        }
        
    } errorIn:^(NSError *error) {
        
    }];

}

@end
