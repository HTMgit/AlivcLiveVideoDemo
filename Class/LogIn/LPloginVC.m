//
//  LPloginVC.m
//  livingPlay
//
//  Created by zyh on 2017/10/9.
//  Copyright © 2017年 zyh. All rights reserved.
//

#import "LPloginVC.h"
#import "LPlivePlayingVC.h"
#import "AlivcLiveViewController.h"


@interface LPloginVC ()

@end

@implementation LPloginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)actionLoginAndPlaying:(id)sender {
    __weak typeof(self) weakSelf = self;
    [ZYHCommonService createASIFormDataRequset:USERLOGINURL param:@{@"username":@"zhangsan",@"password":@"123456"} completion:^(id result, NSError *error) {
        if (error) {
            [ZYHCommonService showMakeToastView:error.localizedDescription];
        }else{
            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
            [userDef setObject:result forKey:@"userInfo"];
            NSError * transforError ;
            LPuserModel * userInfo = [LPuserModel arrayOfModelsFromDictionaries:@[result] error:&transforError].lastObject;
            [weakSelf actionLivePlaying:userInfo];
        }
    }];
//     [self actionLivePlaying:nil];
    
}

-(void)actionLivePlaying:(LPuserModel *)userInfo{
    //默认开始为竖屏
//    LPlivePlayingVC *live = [[LPlivePlayingVC alloc] initWithUrl:ALPushURL isScreenHorizontal:0];
//    [self presentViewController:live animated:YES completion:nil];
    AlivcLiveViewController *live = [[AlivcLiveViewController alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:ALPushURL isScreenHorizontal:0];
    live.emceeInfo = userInfo;
    live.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:live animated:YES];
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
