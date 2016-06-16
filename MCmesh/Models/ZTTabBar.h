//
//  ZTTabBar.h
//  MCmesh
//
//  Created by zhoulanjun on 16/6/7.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZTTabBar;
@protocol ZTTabBarDelegate <UITabBarDelegate>
@optional
-(void)tabBarDidClickPlusButton:(ZTTabBar *)tabBar;
@end

@interface ZTTabBar : UITabBar

@property (nonatomic,weak) id<ZTTabBarDelegate> Mydelegate;

@end
