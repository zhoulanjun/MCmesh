//
//  ZTNavigationController.m
//  MCmesh
//
//  Created by zhoulanjun on 16/6/7.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "ZTNavigationController.h"

@interface ZTNavigationController ()

@end

@implementation ZTNavigationController

+(void)initialize
{
    UIBarButtonItem *item = [UIBarButtonItem appearance];

    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor orangeColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 不可用状态
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionary];
    disableTextAttrs[NSForegroundColorAttributeName] = [UIColor redColor];
    disableTextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    [item setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


#pragma mark -重写父类的方法
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count >0 )
    {
        viewController.hidesBottomBarWhenPushed = YES;
        // 定义leftBarButtonItemz
        // 定义leftBarButtonItem
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTargat:self action:@selector(back) image:@"navigationbar_back" highImage:@"navigationbar_back_highlighted"];
        
        // 定义rightBarButtonItem
//        viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTargat:self action:@selector(more) image:@"navigationbar_more" highImage:@"navigationbar_more_highlighted"];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back
{
    // 这里要用self，不能用self.navigationViewController，因为self本身就是导航控制器对象，self.navigationViewController是nil
    [self popViewControllerAnimated:YES];
}

//- (void)more
//{
//    [self popToRootViewControllerAnimated:YES];
//}


@end
