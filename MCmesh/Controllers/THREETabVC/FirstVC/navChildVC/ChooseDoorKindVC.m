//
//  ChooseDoorKindVC.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/30.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "ChooseDoorKindVC.h"
#import "AddPerperalNodesVC.h"

@interface ChooseDoorKindVC ()

@end

@implementation ChooseDoorKindVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title=@"单门 或者 双门";
    
    
//    选完车库门类型后 跳转到deviceList界面
    UIButton *OneDoorBtn=[[UIButton alloc]initWithFrame:CGRectMake(30, 460, 190, 40)];
    [self.view addSubview:OneDoorBtn];
    OneDoorBtn.center=CGPointMake(VIEWWIDTH/2, 460);
    [OneDoorBtn setTitle:@"单门（test）" forState:UIControlStateNormal];
    [OneDoorBtn setTitleShadowColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    OneDoorBtn.backgroundColor=[UIColor redColor];
    [OneDoorBtn addTarget:self action:@selector(ChooseDoorBtn) forControlEvents:UIControlEventTouchUpInside];
}

-(void)ChooseDoorBtn
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
    AddPerperalNodesVC *apv=[[AddPerperalNodesVC alloc]init];
    [self.navigationController pushViewController:apv animated:YES];
    
    
}

@end
