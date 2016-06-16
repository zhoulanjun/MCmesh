//
//  AppDelegate.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/12.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "RootViewController.h"

#define USERNAME @"lanjun@163.com"
#define PASSWORD @"123456"


@interface AppDelegate ()
{
    Reachability * hostReach;
    NetworkStatus netstatus;//网络状态
    BOOL   _isConnected;   // 网络连接
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSLog(@"缩放因子为：%f",[UIScreen mainScreen].nativeScale);
    
    //添加内部打印日志
    NSLog(@"%@",NSHomeDirectory());
//    [self redirectNSlogToDocumentFolder];
    
    
//    reachibility  开始监控网络
        [self reachibilityTheWeb];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    User *user=[User sharedUser];
    user.userName=USERNAME;
    user.password=PASSWORD;
    RootViewController *nvc=[[RootViewController alloc]init];
    self.window.rootViewController = nvc;
 
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - 每次启动都保存一个日志
- (void)redirectNSlogToDocumentFolder
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"]; //每次启动后都保存一个新的日志文件中
    NSString *logName = [formatter stringFromDate:[NSDate date]];
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.log",logName];//注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    //先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

#pragma mark - reachibility
- (void)reachibilityTheWeb
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
    [hostReach startNotifier];
}
//开始监控网络
- (void)reachabilityChanged:(NSNotification *)note
{
    
    Reachability * curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    netstatus = [curReach currentReachabilityStatus];
    
    // 网络状态发生变化，通知出去
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetstatus object:nil userInfo:@{@"netStatus":[NSNumber numberWithInt:netstatus]}];
    
    //暂时没用，以便后续扩展使用
    switch (netstatus)
    {
        case NotReachable:
        [User sharedUser].useNetType=@"NotReachable";
            break;
        case ReachableViaWiFi:
            [User sharedUser].useNetType=@"ReachableViaWiFi";
            break;
        case ReachableViaWWAN:
            [User sharedUser].useNetType=@"ReachableViaWWAN";
            break;
    }
    
    NSLog(@"app用户使用的网络为：%@",[User sharedUser].useNetType);

}

@end
