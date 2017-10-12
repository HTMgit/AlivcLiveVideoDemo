//
//  NMGlobaDefine.h
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/10.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#ifndef NMGlobaDefine_h
#define NMGlobaDefine_h

//推流地址
#define ALPushURL @"rtmp://video-center.alivecdn.com/AppName/StreamName?vhost=live.ymz008.com&auth_key=1507542025-0-0-448ab45535d9b30c79d71db08ad2beb2"
//用户登陆地址
#define USERLOGINURL @"http://192.168.200.25/stlive/userSign/login"


//----------------------------------颜色--------------------------------------{
#define fRgbColor(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1]
#define fRgbaColor(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define fNMHexColor(hex)                                                                                                                                         \    [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]
//----------------------------------颜色--------------------------------------}

//----------------------------------分辨率--------------------------------------{
//设备屏宽
#define kNMDeviceWidth [[UIScreen mainScreen] bounds].size.width
// 设备屏高
#define kNMDeviceHeight [[UIScreen mainScreen] bounds].size.height

#endif /* NMGlobaDefine_h */
