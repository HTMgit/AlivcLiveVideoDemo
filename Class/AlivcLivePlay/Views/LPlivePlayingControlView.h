//
//  LPlivePlayingControlView.h
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/10.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LPlivePlayingControlView;
@protocol LPlivePlayingControlViewDelegate<NSObject>
-(void)livePlayingControl:(int)btnNum sender:(id)sender;

@end
//SHSelWitchLockVC
@interface LPlivePlayingControlView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSArray * titleControls;
    NSArray * imgControls;
    UICollectionView * controlCollectionView;
}
@property(nonatomic,weak) id<LPlivePlayingControlViewDelegate> delegate;

//+(LPlivePlayingControlView * )sharedManager;
-(id)initWithFrame:(CGRect)frame;
//-(void)setLoadControlView;
//-(void)setPushStatus:(BOOL)status;//1: 正在推送 0:推送断开
//-(void)setPushDetail:(NSString *)pushStr;//推送详情
//-(void)setShowViewDirection;//手机旋转

@end
