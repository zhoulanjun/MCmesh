//
//  BusyShowView.m
//  Familie
//
//  Created by zhoulanjun on 15/6/17.
//  Copyright (c) 2015年 skylight. All rights reserved.
//

#import "BusyShowView.h"

@implementation BusyShowView

-(UIView *)createBusyShow:(UIView *)v
{

    _busyShow = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _busyShow.frame = CGRectMake(0, 0, 50, 50);
    [_busyShow setColor: [UIColor blackColor]];
    _busyShow.center=v.center;
    return _busyShow;
}



-(void)startAnima
{
    [_busyShow startAnimating];
}
-(void)stopAnima
{
    [_busyShow stopAnimating];
}
@end
