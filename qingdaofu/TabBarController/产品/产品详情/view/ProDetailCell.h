//
//  ProDetailCell.h
//  qingdaofu
//
//  Created by zhixiang on 16/6/8.
//  Copyright © 2016年 zhixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProDetailHeadFootView.h"

@interface ProDetailCell : UITableViewCell

@property (nonatomic,strong) UILabel *deRateLabel;
@property (nonatomic,strong) UILabel *deRateLabel1;

@property (nonatomic,strong) ProDetailHeadFootView *deMoneyView;
@property (nonatomic,strong) ProDetailHeadFootView *deTypeView;

@property (nonatomic,strong) UILabel *deLineLabel;

@property (nonatomic,assign) BOOL didSetupConstraints;

@end
