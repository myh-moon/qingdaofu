//
//  RegisterAgreementViewController.m
//  qingdaofu
//
//  Created by zhixiang on 16/7/7.
//  Copyright © 2016年 zhixiang. All rights reserved.
//

#import "RegisterAgreementViewController.h"

@interface RegisterAgreementViewController ()

@property (nonatomic,assign) BOOL didSetupconstraints;
@property (nonatomic,strong) UIWebView *registerWebview;

@end

@implementation RegisterAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.agreeString isEqualToString:kRegisterAgreement]) {
        self.title = @"注册协议";
    }else{
        self.title = @"常见问答";
    }
    self.navigationItem.leftBarButtonItem = self.leftItem;
    
    [self.view addSubview: self.registerWebview];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    if (!self.didSetupconstraints) {
        
        [self.registerWebview autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        self.didSetupconstraints = YES;
    }
    [super updateViewConstraints];
}

- (UIWebView *)registerWebview
{
    if (!_registerWebview) {
        _registerWebview = [UIWebView newAutoLayoutView];
        NSString *registerString = [NSString stringWithFormat:@"%@%@",kQDFTestImageString,self.agreeString];
        NSURL *url = [NSURL URLWithString:registerString];
        [_registerWebview loadRequest:[NSURLRequest requestWithURL:url]];
    }
    return _registerWebview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
