//
//  LPloginVC.m
//  livingPlay
//
//  Created by zyh on 2017/10/9.
//  Copyright © 2017年 zyh. All rights reserved.
//

#import "LPloginVC.h"

#import "LPlivePlayingVC.h"
#import "LPbeginPlayingVC.h"
#import "AlivcLiveViewController.h"


@interface LPloginVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation LPloginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    self.navigationController.navigationBar.translucent = NO;
    
    _btnLogin.layer.cornerRadius = 5;
    _btnLogin.layer.masksToBounds = YES;
    _btnLogin.layer.borderWidth = 1;
    _btnLogin.layer.borderColor = [UIColor orangeColor].CGColor;
    
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
    NSString * requestUrl = [REQUESTURL stringByAppendingString:@"/userSign/login"];
    [ZYHCommonService createASIFormDataRequset:requestUrl param:@{@"username":@"zhangsan",@"password":@"123456"} completion:^(id result, NSError *error) {
        if (error) {
            [ZYHCommonService showMakeToastView:error.localizedDescription];
        }else{
            NSDictionary * dicResult =[NSDictionary dictionaryWithDictionary:result];
            if([dicResult.allKeys containsObject:@"errmsg"]) {
                [ZYHCommonService showMakeToastView:[NSString stringWithFormat:@"%@:%@",result[@"errmsg"],result[@"errcode"]]];
                return ;
            }else {
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary * dicScreen= [NSMutableDictionary dictionaryWithCapacity:0];
                for (int i = 0; i<dicResult.allKeys.count; i++) {
                    NSString *key = dicResult.allKeys[i];
                    id obj = [dicResult objectForKey:key];
                    if([obj isKindOfClass:[NSString class]]){
                        NSString * str =obj;
                        if (![ZYHCommonService isBlankString:str]) {
                            [dicScreen setObject:obj forKey:key];
                        }
                    }else if([obj isKindOfClass:[NSNull class]]){
                        continue;
                    }else{
                        if (obj) {
                                [dicScreen setObject:obj forKey:key];
                        }
                    }
                    NSLog(@"%@:%@",key,obj);
                }
                
            [userDef setObject:dicScreen forKey:@"userInfo"];
            [weakSelf actionLivePlaying:nil];
            }
        }
    }];
//     [self actionLivePlaying:nil];
    
}

-(void)actionLivePlaying:(LPuserModel *)userInfo{
    //默认开始为竖屏
//    LPlivePlayingVC *live = [[LPlivePlayingVC alloc] initWithUrl:ALPushURL isScreenHorizontal:0];
//    [self presentViewController:live animated:YES completion:nil];

//    AlivcLiveViewController *live = [[AlivcLiveViewController alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:ALPushURL isScreenHorizontal:0];
//    live.emceeInfo = userInfo;
//    live.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:live animated:YES];
    
    LPbeginPlayingVC *live = [[LPbeginPlayingVC alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:live];
    [self presentViewController:nav animated:YES completion:nil];
//    live.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:live animated:YES];
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
