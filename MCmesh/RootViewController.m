//
//  RootViewController.m
//  MCmesh
//
//  Created by zhoulanjun on 16/6/7.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "SecondViewController.h"
#import "ZTNavigationController.h"  // 自定义导航控制器
#import "ZTTabBar.h"  // 自定义tabBar


@interface RootViewController ()<ZTTabBarDelegate>
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCustomTabBar];
}

- (void)initCustomTabBar
{
    [self addChildVc:[[ViewController alloc] init] title:@"Camera" image:@"Triangle_left"selectedImage:@"triangle_left_selected"];
    [self addChildVc:[[SecondViewController alloc] init] title:@"Event" image:@"Circle" selectedImage:@"Circle_selected"];

    [self addChildVc:[[SecondViewController alloc] init] title:@"Account" image:@"Square" selectedImage:@"Square_selected"];
    
    
//    ZTTabBar *tabBar = [[ZTTabBar alloc]init];
//    tabBar.Mydelegate=self;
//    // 给tabBar传递tabBarItem模型
//    // KVC：如果要修系统的某些属性，但被设为readOnly，就是用KVC，即setValue：forKey：。
//    // 修改tabBar为自定义tabBar
//    [self setValue:tabBar forKey:@"tabBar"];
    
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */

- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置子控制器的文字(可以设置tabBar和navigationBar的文字)
    childVc.title = title;
    
    // 设置子控制器的tabBarItem图片
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    // 禁用图片渲染
    childVc.view.backgroundColor=APPBACKCOLOR;
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//     设置文字的样式
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]} forState:UIControlStateSelected];

    
    // 为子控制器包装导航控制器
    ZTNavigationController *navigationVc = [[ZTNavigationController alloc] initWithRootViewController:childVc];
    
    // 添加子控制器
    [self addChildViewController:navigationVc];
}


#pragma ZTTabBarDelegate
/**
 *  加号按钮点击
 */
- (void)tabBarDidClickPlusButton:(ZTTabBar *)tabBar
{
    // 点击事件内容
    UIViewController *vc = [[UIViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
