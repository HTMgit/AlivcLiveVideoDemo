//
//  LPlivePlayingControlView.m
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/10.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#import "LPlivePlayingControlView.h"
#import "SHSelLockCell.h"

@implementation LPlivePlayingControlView{
    UIView *viewBlackBack; //
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        titleControls = @[@"横屏",@"切换镜头",@"闪光灯",@"美颜",@"静音"];
        imgControls = @[@"m_HVchange",@"m_camera",@"m_light",@"m_beauty",@"m_mute"];
        float w = (kNMDeviceWidth-1) / 5;
        float h = w /0.6 ;/// 0.8;
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.itemSize = CGSizeMake(w, h);
        flowlayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        controlCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:flowlayout];
//
        [controlCollectionView registerClass:[SHSelLockCell class] forCellWithReuseIdentifier:@"SHSelLockCell"];
        controlCollectionView.dataSource = self;
        controlCollectionView.delegate = self;
        controlCollectionView.showsHorizontalScrollIndicator = NO;
        controlCollectionView.showsVerticalScrollIndicator = NO;
        controlCollectionView.backgroundColor = [UIColor whiteColor];
        controlCollectionView.scrollEnabled = NO;
        
        viewBlackBack = [[UIView alloc]init];
        viewBlackBack.backgroundColor =[UIColor blackColor];
        viewBlackBack.alpha = 0.3;
        UITapGestureRecognizer * tapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionCancelControl:)];
        [viewBlackBack addGestureRecognizer:tapGesture];
        
        [self addSubview:viewBlackBack];
        [self addSubview:controlCollectionView];
        
        [controlCollectionView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.height.mas_equalTo(h+30);
        }];
        [viewBlackBack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
    }
    
    
    return self;
}

#pragma mark -collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return titleControls.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    
//}
//- (UICollectionViewFlowLayout *)flowLayout {
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.headerReferenceSize = CGSizeMake(kNMDeviceWidth, 30.0f); //设置head大小
//    return flowLayout;
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"SHSelLockCell";

    SHSelLockCell * cell =[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.lockImg.image=[UIImage imageNamed:imgControls[indexPath.row]];
    cell.lockName.text = titleControls[indexPath.row];
    UITapGestureRecognizer * tapGestureCell =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionCellControl:)];
    [cell addGestureRecognizer:tapGestureCell];
    
    
//    cell.lockImg.userInteractionEnabled = NO;
//    cell.lockName.userInteractionEnabled = NO;
//    cell.userInteractionEnabled = YES;
//    cell.lockImg.hidden = YES;
//     cell.lockName.hidden = YES;
    return cell;
}
    
    
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(livePlayingControl:sender:)]) {
        [self.delegate livePlayingControl:(int)indexPath.row sender:nil];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)actionCellControl:(UIGestureRecognizer *)sender{
    SHSelLockCell * cell  =  (SHSelLockCell *)sender.view;
    NSIndexPath * indexPath = [controlCollectionView indexPathForCell:cell];
    if ([self.delegate respondsToSelector:@selector(livePlayingControl:sender:)]) {
        [self.delegate livePlayingControl:(int)indexPath.row sender:nil];
    }
}
    
-(void)actionCancelControl:(id)sender{
    if ([self.delegate respondsToSelector:@selector(livePlayingControl:sender:)]) {
        [self.delegate livePlayingControl:-1 sender:nil];
    }
}

@end











