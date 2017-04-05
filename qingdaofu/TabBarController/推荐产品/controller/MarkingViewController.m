//
//  MarkingViewController.m
//  qingdaofu
//
//  Created by zhixiang on 16/6/3.
//  Copyright © 2016年 zhixiang. All rights reserved.
//

#import "MarkingViewController.h"

@interface MarkingViewController ()

@property (nonatomic,assign) BOOL didSetupConstraints;
@property (nonatomic,strong) UIWebView *markingWebView;

@end

@implementation MarkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.navTitle;
    self.navigationItem.leftBarButtonItem = self.leftItem;
    
    [self.view addSubview:self.markingWebView];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        [self.markingWebView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

- (UIWebView *)markingWebView
{
    if (!_markingWebView) {
        _markingWebView = [UIWebView newAutoLayoutView];
        NSURL *markUrl = [NSURL URLWithString:self.markString];
        [_markingWebView loadRequest:[NSURLRequest requestWithURL:markUrl]];
        [_markingWebView setScalesPageToFit:YES];//自动缩放以适应屏幕
        _markingWebView.mediaPlaybackRequiresUserAction = YES;
    }

    return _markingWebView;
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
