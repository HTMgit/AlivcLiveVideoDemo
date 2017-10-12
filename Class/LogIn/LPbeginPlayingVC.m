//
//  LPbeginPlayingVC.m
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/11.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#import "LPbeginPlayingVC.h"

#import "LPloginVC.h"
#import "AlivcLiveViewController.h"

@interface LPbeginPlayingVC ()

@end

@implementation LPbeginPlayingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"直播大厅";
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBeginLivePlaying:(id)sender {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dicUserInfo = [userDefaults objectForKey:@"userInfo"];
    if (!dicUserInfo) {
        [ZYHCommonService showMakeToastView:@"未搜索到用户"];
    }else{
        NSError * transforError ;
        LPuserModel * userInfo = [LPuserModel arrayOfModelsFromDictionaries:@[dicUserInfo] error:&transforError].lastObject;
        AlivcLiveViewController *live = [[AlivcLiveViewController alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:ALPushURL isScreenHorizontal:0];
        live.emceeInfo = userInfo;
        live.hidesBottomBarWhenPushed = YES;
        [self.navigationController hidesBottomBarWhenPushed];
        [self.navigationController pushViewController:live animated:YES];
    }
}

- (IBAction)actionCutOutUser:(id)sender {
    LPloginVC *login = [[LPloginVC alloc] init];
    UINavigationController * nav =[[UINavigationController alloc]initWithRootViewController:login];
//    self.window.rootViewController = nav;
    [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
