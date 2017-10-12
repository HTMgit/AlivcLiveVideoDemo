//
//  ViewController.m
//  DevAlivcLiveVideo
//
//  Created by LYZ on 16/6/12.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import "ViewController.h"
#import "LPlivePlayingVC.h"
#import "AlivcLiveViewController.h"
#import <AlivcLiveVideo/AlivcLiveVideo.h>

@interface ViewController ()

@property(nonatomic, copy) NSString* pushUrl;
@property (weak, nonatomic) IBOutlet UITextField *pushURLTextField;
@property (weak, nonatomic) IBOutlet UISwitch *screenSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pushURLTextField.clearsOnBeginEditing = YES;
}


#pragma mark - Action
- (IBAction)switchAction:(UISwitch *)sender {
    
    if ([sender isOn]) {
        [sender setOn:YES];
    } else {
        [sender setOn:NO];
    }
}

- (IBAction)startButtonClick:(id)sender {

    self.pushUrl = self.pushURLTextField.text;
    self.pushUrl = ALPushURL;
    if (![self.pushUrl containsString:@"rtmp://"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推流地址格式错误，无法直播" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    AlivcLiveViewController *live = [[AlivcLiveViewController alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:self.pushUrl isScreenHorizontal:!self.screenSwitch.on];
    [self presentViewController:live animated:YES completion:nil];
    
//initWithUrl:self.pushUrl isScreenHorizontal:];
//    LPlivePlayingVC *live = [[LPlivePlayingVC alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:self.pushUrl isScreenHorizontal:!self.screenSwitch.on];
//    [self presentViewController:live animated:YES completion:nil];
    
}

@end

