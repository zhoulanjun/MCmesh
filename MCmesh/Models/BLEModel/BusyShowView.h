//
//  BusyShowView.h
//  Familie
//
//  Created by zhoulanjun on 15/6/17.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusyShowView : UIView

@property (nonatomic,strong)UIActivityIndicatorView *busyShow;

-(UIView *)createBusyShow:(UIView *)v;

-(void)startAnima;

-(void)stopAnima;


@end
