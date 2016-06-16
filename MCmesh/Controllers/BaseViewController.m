//
//  BaseViewController.m
//  MCmesh
//
//  Created by zhoulanjun on 16/6/8.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@end

@implementation BaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=APPBACKCOLOR;
    
    //mansory约束，所有子视图要继承的背景约束视图
    WS(ws);
    UIView *constrainView = [UIView new];
    constrainView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:constrainView];
    _constrainView=constrainView;
    [constrainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(ws.view);
        make.edges.equalTo(ws.view).with.insets(UIEdgeInsetsMake(64,10,10,10));
    }];
    
    
}


//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //    [_nsc removeObFor:self];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationNetstatus
                                                  object:nil];
}
@end
