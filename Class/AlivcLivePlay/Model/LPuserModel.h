//
//  LPuserModel.h
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/11.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface LPuserModel : JSONModel

@property(nonatomic,strong)NSString<Optional> * username;
@property(nonatomic,strong)NSString<Optional> * nickname;
@property(nonatomic,strong)NSString<Optional> * faceUrl;
@property(nonatomic,strong)NSString<Optional> * frontUrl;

@property(nonatomic,strong)NSString<Optional> * signupTime;
@property(nonatomic,strong)NSString<Optional> * signinTime;
@property(nonatomic,strong)NSString<Optional> * vcInValidTime;
@property(nonatomic,strong)NSString<Optional> * vc;
@property(nonatomic,strong)NSString<Optional> * brief;//直播间描述
@property(nonatomic,assign)int sex;
@property(nonatomic,assign)BOOL isZhubo;
@property(nonatomic,assign)BOOL isBlacklist;
@end
