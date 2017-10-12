//
//  AlivcLiveViewController.h
//  DevAlivcLiveVideo
//
//  Created by yly on 16/3/21.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlivcLiveViewController : UIViewController
@property(nonatomic ,strong)LPuserModel * emceeInfo;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url isScreenHorizontal:(BOOL)isScreenHorizontal;

@end
