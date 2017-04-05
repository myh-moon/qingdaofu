//
//  ProductsDetailsViewController.m
//  qingdaofu
//
//  Created by zhixiang on 16/5/16.
//  Copyright © 2016年 zhixiang. All rights reserved.
//

#import "ProductsDetailsViewController.h"

#import "UIImage+Color.h"
#import "BaseCommitButton.h"
#import "EvaTopSwitchView.h"  //切换
#import "ProdLeftView.h"  //产品基本信息
#import "UIButton+WebCache.h"

//cell
#import "MineUserCell.h"
#import "ProDetailCell.h"
#import "ProDetailNumberCell.h"  //浏览次数
#import "EvaluatePhotoCell.h"

////////////
#import "ProductDetailResponse.h"
#import "ApplyRecordModel.h"
#import "ProductDetailModel.h"
#import "CompleteResponse.h"
#import "CertificationModel.h"

@interface ProductsDetailsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) BOOL didSetupConstraints;
@property (nonatomic,strong) UIImage *shadowImage;
@property (nonatomic,strong) UIButton *leftItemButton;
@property (nonatomic,strong) UIButton *rightItemButton;
@property (nonatomic,strong) UITableView *productsDetailsTableView;
@property (nonatomic,strong) BaseCommitButton *proDetailsCommitButton;
@property (nonatomic,strong)  UIView *headerView;
@property (nonatomic,strong) ProdLeftView *leftTableView;

//json
@property (nonatomic,strong) NSString *typetString;//收藏状态(1-已收藏，2-未收藏)
@property (nonatomic,strong) NSArray *messageArray1;
@property (nonatomic,strong) NSArray *messageArray11;
@property (nonatomic,strong) NSArray *messageArray2;
@property (nonatomic,strong) NSArray *messageArray22;
@property (nonatomic,strong) NSArray *certificationArray1;
@property (nonatomic,strong) NSArray *certificationArray11;
@property (nonatomic,strong) NSString *casedesc;

@property (nonatomic,strong) NSString *switchType; //切换产品详情or发布方信息
@property (nonatomic,assign) BOOL isRefreshNewProduct; //返回上一页面，是否需要刷新

@property (nonatomic,strong) NSMutableArray *recommendDataArray; //产品信息
@property (nonatomic,strong) NSMutableArray *certifiDataArray;  //身份认证信息

@end

@implementation ProductsDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x0da3f8)] forBarMetrics:UIBarMetricsDefault];
    
    self.shadowImage = self.navigationController.navigationBar.shadowImage;
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:UIColorFromRGB(0x0da3f8)]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setShadowImage:self.shadowImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftItemButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    
    self.switchType = @"33";
    
    [self.view addSubview:self.productsDetailsTableView];
    [self.view addSubview:self.proDetailsCommitButton];
    [self.view setNeedsUpdateConstraints];
    
    [self getDetailMessageOfProduct];
}

- (UIButton *)leftItemButton
{
    if (!_leftItemButton) {
        _leftItemButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_leftItemButton setImage:[UIImage imageNamed:@"nav_back"] forState:0];
        QDFWeakSelf;
        [_leftItemButton addAction:^(UIButton *btn) {
            [weakself.navigationController popViewControllerAnimated:YES];
            if (weakself.didRefreshNewProduct) {
                weakself.didRefreshNewProduct(weakself.isRefreshNewProduct);
            }
        }];
    }
    return _leftItemButton;
}

- (UIButton *)rightItemButton
{
    if (!_rightItemButton) {
        _rightItemButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _rightItemButton;
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        
        [self.productsDetailsTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [self.productsDetailsTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.proDetailsCommitButton];
        
        [self.proDetailsCommitButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.proDetailsCommitButton autoSetDimension:ALDimensionHeight toSize:kTabBarHeight];
        
        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

- (UITableView *)productsDetailsTableView
{
    if (!_productsDetailsTableView) {
        _productsDetailsTableView = [UITableView newAutoLayoutView];
        _productsDetailsTableView.backgroundColor = kBackColor;
        _leftTableView.separatorColor = kSeparateColor;
        _productsDetailsTableView.delegate = self;
        _productsDetailsTableView.dataSource = self;
        _productsDetailsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kBigPadding)];
    }
    return _productsDetailsTableView;
}

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50+kBigPadding)];
        
        EvaTopSwitchView *productSwitchView = [[EvaTopSwitchView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        productSwitchView.widthBlueConstraints.constant = kScreenWidth/2;
        productSwitchView.backgroundColor = kWhiteColor;
        [productSwitchView.getbutton  setTitle:@"产品信息" forState:0];//33
        [productSwitchView.sendButton  setTitle:@"发布方信息" forState:0];//34
        [productSwitchView.shortLineLabel setHidden:YES];
        [self.headerView addSubview:productSwitchView];
        
        QDFWeak(productSwitchView);
        QDFWeakSelf;
        [productSwitchView setDidSelectedButton:^(NSInteger tag) {
            if (tag == 33) {//产品信息
                weakself.switchType = @"33";
                
                if (weakself.messageArray1.count == 0) {
                    [weakself getDetailMessageOfProduct];
                }else{
                    [weakself.productsDetailsTableView reloadData];
                }
                
            }else{//发布人信息
                if (self.certifiDataArray.count > 0) {
                    
                    CertificationModel *certificationModel = self.certifiDataArray[0];
                    
                    if (certificationModel.state && [certificationModel.state integerValue] == 1) {
                        weakself.switchType = @"34";
                        [weakself.productsDetailsTableView reloadData];
                    }else{
                        weakself.switchType = @"33";
                        [weakproductSwitchView.getbutton setTitleColor:kBlueColor forState:0];
                        [weakproductSwitchView.sendButton setTitleColor:kBlackColor forState:0];
                        weakproductSwitchView.leftBlueConstraints.constant = 0;
                        [weakself showHint:@"发布方未认证，不能查看相关信息"];
                    }
                    
                }else{
                    weakself.switchType = @"33";
                    [weakproductSwitchView.getbutton setTitleColor:kBlueColor forState:0];
                    [weakproductSwitchView.sendButton setTitleColor:kBlackColor forState:0];
                    weakproductSwitchView.leftBlueConstraints.constant = 0;
                    [weakself showHint:@"发布方未认证，不能查看相关信息"];
                }
            }
        }];
    }
    return _headerView;
}

- (BaseCommitButton *)proDetailsCommitButton
{
    if (!_proDetailsCommitButton) {
        _proDetailsCommitButton = [BaseCommitButton newAutoLayoutView];
    }
    return _proDetailsCommitButton;
}

- (NSMutableArray *)recommendDataArray
{
    if (!_recommendDataArray) {
        _recommendDataArray = [NSMutableArray array];
    }
    return _recommendDataArray;
}

- (NSMutableArray *)certifiDataArray
{
    if (!_certifiDataArray) {
        _certifiDataArray = [NSMutableArray array];
    }
    return _certifiDataArray;
}

#pragma mark - tableView deleagate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.recommendDataArray.count > 0) {
        return 2;
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else{//section==1
        if ([self.switchType isEqualToString:@"33"]) {
            //产品信息
            return 7;
        }else{
            //发布人信息
            if (self.certificationArray1.count > 0) {
                return self.certificationArray1.count+1;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 190;
        }
        return kCellHeight3;
    }
    
    //section==1
    if ([self.switchType isEqualToString:@"33"]) {//产品信息
        return kCellHeight;
    }else if ([self.switchType isEqualToString:@"34"]) {//发布方信息
        if (indexPath.row == self.certificationArray1.count) {//分割线
            return kBigPadding;
        }else if (indexPath.row == self.certificationArray1.count+2){//评价信息
            return 105;
        }
        return kCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier;
    
    ProductDetailModel *prodDetailModel = self.recommendDataArray[0];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//产品详情
            identifier = @"proDetais00";
            ProDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[ProDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColorFromRGB(0x0da3f8);
            
            if ([prodDetailModel.typeLabel isEqualToString:@"万"]) {
                cell.deRateLabel.text = @"----    固定费用    ----";
            }else if ([prodDetailModel.typeLabel isEqualToString:@"%"]){
                cell.deRateLabel.text = @"----    风险费率    ----";
            }
            NSString *agencyStr1 = prodDetailModel.typenumLabel;
            NSString *agencyStr2 = prodDetailModel.typeLabel;
            NSString *agencyStr = [NSString stringWithFormat:@"%@%@",agencyStr1,agencyStr2];
            NSMutableAttributedString *attAgencyStr = [[NSMutableAttributedString alloc] initWithString:agencyStr];
            [attAgencyStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50],NSForegroundColorAttributeName:kWhiteColor} range:NSMakeRange(0, agencyStr1.length)];
            [attAgencyStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24],NSForegroundColorAttributeName:kWhiteColor} range:NSMakeRange(agencyStr1.length, agencyStr2.length)];
            [cell.deRateLabel1 setAttributedText:attAgencyStr];
            
            //左边－－－－委托金额
            cell.deMoneyView.fLabel1.text = @"委托金额";
            NSString *moneyStr1 = prodDetailModel.accountLabel;
            NSString *moneyStr2 = @"万";
            NSString *moneyStr = [NSString stringWithFormat:@"%@%@",moneyStr1,moneyStr2];
            NSMutableAttributedString *attMoneyStr = [[NSMutableAttributedString alloc] initWithString:moneyStr];
            [attMoneyStr addAttributes:@{NSFontAttributeName:kNavFont,NSForegroundColorAttributeName:kWhiteColor} range:NSMakeRange(0, moneyStr1.length)];
            [attMoneyStr addAttributes:@{NSFontAttributeName:kSmallFont,NSForegroundColorAttributeName:kWhiteColor} range:NSMakeRange(moneyStr1.length, moneyStr2.length)];
            [cell.deMoneyView.fLabel2 setAttributedText:attMoneyStr];
            
            //右边 --违约期限
            cell.deTypeView.fLabel1.text = @"违约期限";
            NSString *dateStr1 = prodDetailModel.overdue;
            NSString *dateStr2 = @"个月";
            NSString *dateStr = [NSString stringWithFormat:@"%@%@",dateStr1,dateStr2];
            NSMutableAttributedString *attDateStr = [[NSMutableAttributedString alloc] initWithString:dateStr];
            [attDateStr addAttributes:@{NSFontAttributeName:kNavFont,NSForegroundColorAttributeName:kWhiteColor} range:NSMakeRange(0, dateStr1.length)];
            [attDateStr addAttributes:@{NSFontAttributeName:kSmallFont,NSForegroundColorAttributeName:kWhiteColor} range:NSMakeRange(dateStr1.length, dateStr2.length)];
            [cell.deTypeView.fLabel2 setAttributedText:attDateStr];
        
            return cell;
        }
        
        //row == 1  ProDetailNumberCell
        identifier = @"proDetais01";
        ProDetailNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[ProDetailNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kWhiteColor;
        
        cell.numberButton1.fLabel1.text = @"浏览次数";
        cell.numberButton1.fLabel2.text = [NSString getValidStringFromString:prodDetailModel.browsenumber toString:@"0"];
        cell.numberButton2.fLabel1.text = @"申请次数";
        cell.numberButton2.fLabel2.text = [NSString getValidStringFromString:prodDetailModel.applyTotal toString:@"0"];
        cell.numberButton3.fLabel1.text = @"收藏次数";
        cell.numberButton3.fLabel2.text = [NSString getValidStringFromString:prodDetailModel.collectionTotal toString:@"0"];

        return cell;
    }
    
    //section == 1
    if ([self.switchType isEqualToString:@"33"]) {//产品详情
        identifier = @"proDetais10";
        MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray *arr1;
        if ([prodDetailModel.typeLabel isEqualToString:@"万"]) {
            arr1 = @[@"基本信息",@"债权类型",@"委托事项",@"委托金额",@"固定费用",@"违约期限",@"合同履行地"];
        }else if ([prodDetailModel.typeLabel isEqualToString:@"%"]){
            arr1 = @[@"基本信息",@"债权类型",@"委托事项",@"委托金额",@"风险费率",@"违约期限",@"合同履行地"];
        }
        [cell.userNameButton setTitle:arr1[indexPath.row] forState:0];
        
        if (indexPath.row == 0) {
            [cell.userNameButton setTitleColor:kBlackColor forState:0];
            cell.userNameButton.titleLabel.font = kBigFont;
            [cell.userActionButton setTitle:@"" forState:0];
        }else{
            [cell.userNameButton setTitleColor:kLightGrayColor forState:0];
            cell.userNameButton.titleLabel.font = kFirstFont;
            [cell.userActionButton setTitleColor:kGrayColor forState:0];
            cell.userActionButton.titleLabel.font = kFirstFont;
            if (indexPath.row == 1){
                [cell.userActionButton setTitle:prodDetailModel.categoryLabel forState:0];
            }else if (indexPath.row == 2){
                [cell.userActionButton setTitle:prodDetailModel.entrustLabel forState:0];
            }else if (indexPath.row == 3){
                NSString *account = [NSString stringWithFormat:@"%@万",prodDetailModel.accountLabel];
                [cell.userActionButton setTitle:account forState:0];
            }else if (indexPath.row == 4){
                NSString *typenum = [NSString stringWithFormat:@"%@%@",prodDetailModel.typenumLabel,prodDetailModel.typeLabel];
                [cell.userActionButton setTitle:typenum forState:0];
            }else if (indexPath.row == 5){
                NSString *overdue = [NSString stringWithFormat:@"%@个月",prodDetailModel.overdue];
                [cell.userActionButton setTitle:overdue forState:0];
            }else if (indexPath.row == 6){
                [cell.userActionButton setTitle:prodDetailModel.addressLabel forState:0];
            }
        }
        
        
        return cell;
        
        
//        if (indexPath.row == 0) {
//            identifier = @"proDetais10";
//            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (!cell) {
//                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.userNameButton setTitle:@"基本信息" forState:0];
//            [cell.userActionButton setHidden:YES];
//            
//            return cell;
//        }else{
//            identifier = @"proDetais11";
//            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (!cell) {
//                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            
//            NSArray *array1 = @[@"",@"",@""];
//            
//            return cell;
//        }
//        else if(indexPath.row > 0 && indexPath.row < self.messageArray1.count+1){//基本信息详情
//            identifier = @"proDetais11";
//            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (!cell) {
//                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            
//            [cell.userNameButton setTitleColor:kLightGrayColor forState:0];
//            cell.userNameButton.titleLabel.font = kFirstFont;
//            [cell.userActionButton setTitleColor:kGrayColor forState:0];
//            cell.userActionButton.titleLabel.font = kFirstFont;
//            
//            [cell.userNameButton setTitle:self.messageArray1[indexPath.row-1] forState:0];
//            [cell.userActionButton setTitle:self.messageArray11[indexPath.row-1] forState:0];
//            return cell;
//        }else if (indexPath.row == self.messageArray1.count+1){
//            identifier = @"proDetais12";
//            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (!cell) {
//                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.userNameButton setHidden:YES];
//            [cell.userActionButton setHidden:YES];
//            cell.backgroundColor = kBackColor;
//            
//            return cell;
//        }else if (indexPath.row == self.messageArray1.count+2){//补充信息
//            identifier = @"proDetais13";
//            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (!cell) {
//                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.userActionButton setHidden:YES];
//            [cell.userNameButton setTitle:@"补充信息" forState:0];
//            
//            return cell;
//            
//        }else if (indexPath.row > self.messageArray1.count+2){//补充信息详情
//            identifier = @"proDetais14";
//            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//            if (!cell) {
//                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.userNameButton setTitleColor:kLightGrayColor forState:0];
//            cell.userNameButton.titleLabel.font = kFirstFont;
//            [cell.userActionButton setTitleColor:kGrayColor forState:0];
//            cell.userActionButton.titleLabel.font = kFirstFont;
//            
//            [cell.userNameButton setTitle:self.messageArray2[indexPath.row-self.messageArray1.count-3] forState:0];
//            [cell.userActionButton setTitle:self.messageArray22[indexPath.row-self.messageArray11.count-3] forState:0];
//            
//            return cell;
//        }
    }else{//发布方信息
        if (indexPath.row < self.certificationArray1.count) {
            identifier = @"proDetais20";
            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userNameButton.userInteractionEnabled = NO;
            cell.userActionButton.userInteractionEnabled = NO;

            [cell.userNameButton setTitle:self.certificationArray1[indexPath.row] forState:0];
            [cell.userActionButton setTitle:self.certificationArray11[indexPath.row] forState:0];
            
            if (indexPath.row == 0) {
                [cell.userActionButton setTitleColor:kYellowColor forState:0];
            }else if(indexPath.row > 0 && indexPath.row <self.certificationArray1.count-1){
                [cell.userNameButton setTitleColor:kLightGrayColor forState:0];
                cell.userNameButton.titleLabel.font = kFirstFont;
                [cell.userActionButton setTitleColor:kGrayColor forState:0];
                cell.userActionButton.titleLabel.font = kFirstFont;
            }else if (indexPath.row == self.certificationArray1.count-1){
                [cell.userNameButton setTitleColor:kLightGrayColor forState:0];
                cell.userNameButton.titleLabel.font = kFirstFont;
                [cell.userActionButton setTitleColor:kGrayColor forState:0];
                cell.userActionButton.titleLabel.font = kFirstFont;
                if ([self.casedesc isEqualToString:@"查看"]) {
                    [cell.userActionButton setImage:[UIImage imageNamed:@"list_more"] forState:0];
                }
            }
            
            return cell;
        }else if (indexPath.row == self.certificationArray1.count){
            identifier = @"proDetais21";
            MineUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[MineUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.userNameButton setHidden:YES];
            [cell.userActionButton setHidden:YES];
            cell.backgroundColor = kBackColor;
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1f;
    }
    return 50+kBigPadding;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return self.headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return kBigPadding;
    }
    return 0.1f;
}

#pragma mark - method
//产品详情
- (void)getDetailMessageOfProduct
{
    NSString *detailString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kProductDetailsString];
    NSDictionary *params = @{@"token" : [self getValidateToken],
                             @"productid" : self.productid
                             };
    QDFWeakSelf;
    [self requestDataPostWithString:detailString params:params successBlock:^(id responseObject){
        
        ProductDetailResponse *respongh = [ProductDetailResponse objectWithKeyValues:responseObject];
        
        if ([respongh.code isEqualToString:@"0000"]) {
            
            ProductDetailModel *prodDetailModel = respongh.data;
            //title
            weakself.title = [NSString stringWithFormat:@"债权%@",prodDetailModel.number];
            
            //state
            if ([prodDetailModel.status integerValue] == 20 || [prodDetailModel.status integerValue] == 30 || [prodDetailModel.status integerValue] == 40) {//已撮合
                [weakself.proDetailsCommitButton setTitle:@"已撮合" forState:0];
            }else if ([prodDetailModel.applyPeople integerValue] > 0){//已申请
                if (prodDetailModel.apply && [prodDetailModel.apply.status integerValue] == 10) {
                    [weakself.proDetailsCommitButton setTitle:@"取消申请" forState:0];
                    [weakself.proDetailsCommitButton addAction:^(UIButton *btn) {
                        [weakself cancelApplyWithModel:prodDetailModel];
                    }];
                
                }else{
                    [weakself.proDetailsCommitButton setTitle:@"面谈中" forState:0];
                }
            }else if ([prodDetailModel.applyPeople integerValue] == 0 && ![prodDetailModel.create_by isEqualToString:respongh.userid]){//立即申请
                [weakself.proDetailsCommitButton setTitle:@"立即申请" forState:0];
                [weakself.proDetailsCommitButton addAction:^(UIButton *btn) {
                    [weakself ActionOfApplicationCommitWithModel:prodDetailModel];
                }];
            }else{
                [weakself.productsDetailsTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
                [weakself.proDetailsCommitButton setHidden:YES];
            }
            
            //收藏状态
            if ([prodDetailModel.collectionPeople integerValue] > 0) {
                [weakself.rightButton setImage:[UIImage imageNamed:@"nav_collection_s"] forState:0];
                weakself.typetString = @"1";
            }else{
                [weakself.rightButton setImage:[UIImage imageNamed:@"nav_collection"] forState:0];
                weakself.typetString = @"2";
            }
            
            //债权信息
            [weakself.recommendDataArray addObject:prodDetailModel];
            
            //*********发布人认证信息////////
            if (prodDetailModel.certification) {
                CertificationModel *certificationModel = prodDetailModel.certification;
                [weakself.certifiDataArray addObject:certificationModel];
                NSString *definedStr = @"已认证";
                
                NSString *emailQ = [NSString getValidStringFromString:certificationModel.email];
                NSString *addressQ = [NSString getValidStringFromString:certificationModel.address];
                NSString *enterprisewebsiteQ = [NSString getValidStringFromString:certificationModel.enterprisewebsite];
                NSString *casedescQ = [NSString getValidStringFromString:certificationModel.casedesc];
                if (![casedescQ isEqualToString:@"暂无"]) {
                    casedescQ = @"查看";
                }
                
                if ([certificationModel.category integerValue] == 1) {//个人
                    weakself.certificationArray1 = @[@"基本信息",@"姓名",@"身份证号码",@"身份图片",@"联系电话",@"邮箱"];
                    weakself.certificationArray11 = @[@"已认证个人",certificationModel.name,certificationModel.cardno,definedStr,certificationModel.mobile,emailQ];
                }else if ([certificationModel.category integerValue] == 2){//律所
                    weakself.certificationArray1 = @[@"基本信息",@"律所名称",@"执业证号",@"图片",@"联系人",@"联系方式",@"邮箱",@"经典案例"];
                    weakself.certificationArray11 = @[@"已认证律所",certificationModel.name,certificationModel.cardno,definedStr,certificationModel.contact,certificationModel.mobile,emailQ,casedescQ];
                    weakself.casedesc = certificationModel.casedesc;
                }else if ([certificationModel.category integerValue] == 3){//公司
                    weakself.certificationArray1 = @[@"基本信息",@"公司名称",@"营业执照号",@"图片",@"联系人",@"联系方式",@"企业邮箱",@"公司经营地址",@"公司网站",@"经典案例"];
                    weakself.certificationArray11 = @[@"已认证公司",certificationModel.name,certificationModel.cardno,definedStr,certificationModel.contact,certificationModel.mobile,emailQ,addressQ,enterprisewebsiteQ,casedescQ];
                    weakself.casedesc = certificationModel.casedesc;
                }
            }
            
            [weakself.productsDetailsTableView reloadData];
        }else{
            [weakself showHint:respongh.msg];
        }
        
    } andFailBlock:^(NSError *error){
    }];
}

- (void)cancelApplyWithModel:(ProductDetailModel *)prodDetailModel//取消申请
{
    NSString *cancelString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kMyOrderDetailOfCancelApplyString];
    NSDictionary *params = @{@"applyid" : prodDetailModel.apply.applyid,
                             @"token" : [self getValidateToken]
                             };
    QDFWeakSelf;
    [self requestDataPostWithString:cancelString params:params successBlock:^(id responseObject) {
        BaseModel *appModel = [BaseModel objectWithKeyValues:responseObject];
        [weakself showHint:appModel.msg];
        
        if ([appModel.code isEqualToString:@"0000"]) {
            [weakself getDetailMessageOfProduct];
            weakself.isRefreshNewProduct = YES;
        }
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (void)ActionOfApplicationCommitWithModel:(ProductDetailModel *)prodDetailModel//立即申请
{
    NSString *appString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kProductDetailOfApply];
    NSDictionary *params = @{@"productid" : prodDetailModel.productid,
                             @"token" : [self getValidateToken]
                             };
    QDFWeakSelf;
    [self requestDataPostWithString:appString params:params successBlock:^(id responseObject) {
        BaseModel *appModel = [BaseModel objectWithKeyValues:responseObject];
        [weakself showHint:appModel.msg];
        
        if ([appModel.code isEqualToString:@"0000"]) {
            [weakself getDetailMessageOfProduct];
            weakself.isRefreshNewProduct = YES;
        }
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (void)rightItemAction
{
    NSString *saveString;
    NSDictionary *params;
    
    ProductDetailModel *prodDetailModel = self.recommendDataArray[0];
    if ([self.typetString integerValue] == 1) {//已收藏－>未收藏(取消收藏)
        saveString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kProductDetailOfCancelSave];
        params = @{@"token" : [self getValidateToken],
                   @"productid" : prodDetailModel.productid
                   };
    }else if ([self.typetString integerValue] == 2) {//未收藏－>已收藏(收藏)
        saveString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kProductDetailOfSave];
        params = @{@"token" : [self getValidateToken],
                   @"productid" : prodDetailModel.productid,
                   @"create_by" : prodDetailModel.create_by
                   };
    }
    
    QDFWeakSelf;
    [self requestDataPostWithString:saveString params:params successBlock:^(id responseObject) {
        BaseModel *baseModel = [BaseModel objectWithKeyValues:responseObject];
        [weakself showHint:baseModel.msg];
        if ([baseModel.code isEqualToString:@"0000"]) {
            if ([weakself.typetString integerValue] == 1){
                [weakself.rightButton setImage:[UIImage imageNamed:@"nav_collection"] forState:0];
                weakself.typetString = @"2";
            }else{
                [weakself.rightButton setImage:[UIImage imageNamed:@"nav_collection_s"] forState:0];
                weakself.typetString = @"1";
            }
            weakself.isRefreshNewProduct = YES;
        }
    
    } andFailBlock:^(NSError *error) {
        
    }];
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
