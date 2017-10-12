//
//  AppDelegate.m
//  AlivcLiveVideoDemo
//
//  Created by lyz on 16/6/13.
//  Copyright © 2016年 Alibaba Video Cloud. All rights reserved.
//

#import "AppDelegate.h"

#import "LPloginVC.h"
#import "LPbeginPlayingVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dicUserInfo = [userDefaults objectForKey:@"userInfo"];
    BOOL isLogin = 1;
    if (dicUserInfo) {
        NSDate * now = [NSDate date];
        //        NSString * nowStr = [ZYHCommonService stringFromDateWithDate:now formatStr:@"YYYY-MM-dd HH:mm:ss"];
        //        NSDate * now = [ZYHCommonService nsdateFromString:@"2017-11-10 15:35:13" WithFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate * vcInvalid = [ZYHCommonService nsdateFromString:dicUserInfo[@"vcInValidTime"] WithFormat:@"YYYY-MM-dd HH:mm:ss"];
        long difHours1 = [ZYHCommonService timeDifferentNum:vcInvalid endDate:now type:2];
        if (difHours1 < 25) {
            isLogin = YES;
        }else{
            isLogin = NO;
        }
    }
    
    if (isLogin) {
        LPloginVC *login = [[LPloginVC alloc] init];
        UINavigationController * nav =[[UINavigationController alloc]initWithRootViewController:login];
        self.window.rootViewController = nav;
    }else{
        LPbeginPlayingVC *login = [[LPbeginPlayingVC alloc] init];
        UINavigationController * nav =[[UINavigationController alloc]initWithRootViewController:login];
        self.window.rootViewController = nav;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return  YES;
}


//设备选择
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow* )window
{
    if (_allowRotation == 1) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return (UIInterfaceOrientationMaskPortrait);
    }
}

@end
