//
//  SHSelLockCell.m
//  SmartHome
//
//  Created by zyh on 2017/8/14.
//  Copyright © 2017年 gtscn. All rights reserved.
//

#import "SHSelLockCell.h"

@implementation SHSelLockCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews =
        [[NSBundle mainBundle] loadNibNamed:@"SHSelLockCell"
                                      owner:self
                                    options:nil];
        self = [arrayOfViews objectAtIndex:0];
        return self;
    }
    return self;
}


@end
