//
//  LPuserModel.h
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/11.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface LPuserModel : JSONModel

@property(nonatomic,strong)NSString * nickname;
@property(nonatomic,strong)NSString * faceUrl;

@property(nonatomic,strong)NSString * signupTime;
@property(nonatomic,strong)NSString * signinTime;
@property(nonatomic,strong)NSString * vcInValidTime;
@property(nonatomic,strong)NSString * vc;
@property(nonatomic,assign)BOOL isZhubo;
@property(nonatomic,assign)BOOL isBlacklist;
@end
