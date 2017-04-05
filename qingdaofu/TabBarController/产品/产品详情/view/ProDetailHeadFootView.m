//
//  ProDetailHeadFootView.m
//  qingdaofu
//
//  Created by zhixiang on 16/5/16.
//  Copyright © 2016年 zhixiang. All rights reserved.
//

#import "ProDetailHeadFootView.h"

@implementation ProDetailHeadFootView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:self.fLabel1];
        [self addSubview:self.fLabel2];
        
        self.topConstant = [self.fLabel1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:16];

        self.spaceConstant = [self.fLabel2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.fLabel1 withOffset:8];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        
        [self.fLabel1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        [self.fLabel2 autoAlignAxis:ALAxisVertical toSameAxisOfView:self.fLabel1];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (UILabel *)fLabel1
{
    if (!_fLabel1) {
        _fLabel1 = [UILabel newAutoLayoutView];
        _fLabel1.textColor = kLightWhiteColor;
        _fLabel1.font = kSecondFont;
    }
    return _fLabel1;
}

- (UILabel *)fLabel2
{
    if (!_fLabel2) {
        _fLabel2 = [UILabel newAutoLayoutView];
        _fLabel2.textColor = kWhiteColor;
        _fLabel2.font = kFirstFont;
    }
    return _fLabel2;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
