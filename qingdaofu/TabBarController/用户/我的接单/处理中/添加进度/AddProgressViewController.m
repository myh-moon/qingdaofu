//
//  AddProgressViewController.m
//  qingdaofu
//
//  Created by zhixiang on 16/10/21.
//  Copyright © 2016年 zhixiang. All rights reserved.
//

#import "AddProgressViewController.h"

#import "EditDebtAddressCell.h"
#import "TakePictureCell.h"
#import "AgentCell.h"

#import "AddProgressResponse.h"
#import "AddProgressModel.h"

#import "UIViewController+MutipleImageChoice.h"
#import "UIViewController+BlurView.h"

@interface AddProgressViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,assign) BOOL didSetupConstraints;
@property (nonatomic,strong) UITableView *addProgressTableView;
@property (nonatomic,strong) UIView *addBackView;
@property (nonatomic,strong) UIPickerView *addProgressPickerView;

//params
@property (nonatomic,strong) NSMutableDictionary *addPaceDic;

@property (nonatomic,strong) NSMutableArray *evaImageArray;
@property (nonatomic,strong) NSMutableArray *addDataArray;

@end

@implementation AddProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加进度";
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [self.rightButton setTitle:@"保存" forState:0];
    
    [self.view addSubview:self.addProgressTableView];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        
        [self.addProgressTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

- (UITableView *)addProgressTableView
{
    if (!_addProgressTableView) {
        _addProgressTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _addProgressTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _addProgressTableView.backgroundColor = kBackColor;
        _addProgressTableView.separatorColor = kSeparateColor;
        _addProgressTableView.delegate = self;
        _addProgressTableView.dataSource = self;
    }
    return _addProgressTableView;
}

- (UIView *)addBackView
{
    if (!_addBackView) {
        _addBackView = [UIView newAutoLayoutView];
        _addBackView.backgroundColor = UIColorFromRGB1(0x333333, 0.3);
        
        
        UIButton *cancelAddButton = [UIButton newAutoLayoutView];
        cancelAddButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancelAddButton setContentEdgeInsets:UIEdgeInsetsMake(0, kSmallPadding, 0, 0)];
        [cancelAddButton setTitle:@"取消" forState:0];
        [cancelAddButton setTitleColor:kBlueColor forState:0];
        [cancelAddButton setBackgroundColor:kWhiteColor];
        cancelAddButton.titleLabel.font = kBigFont;
        QDFWeakSelf;
        [cancelAddButton addAction:^(UIButton *btn) {
            [weakself hiddenAddPickerView];
        }];
        
        UIButton *okAddButton = [UIButton newAutoLayoutView];
        okAddButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [okAddButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, kSmallPadding)];
        [okAddButton setTitle:@"确定" forState:0];
        [okAddButton setTitleColor:kBlueColor forState:0];
        [okAddButton setBackgroundColor:kWhiteColor];
        okAddButton.titleLabel.font = kBigFont;
        [okAddButton addAction:^(UIButton *btn) {
            AgentCell *cell = [weakself.addProgressTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            cell.agentTextField.text = weakself.addPaceDic[@"name"];
            [weakself hiddenAddPickerView];
        }];

        [_addBackView addSubview:cancelAddButton];
        [_addBackView addSubview:okAddButton];
        [_addBackView addSubview:self.addProgressPickerView];
        
        [cancelAddButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.addProgressPickerView];
        [cancelAddButton autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [cancelAddButton autoSetDimensionsToSize:CGSizeMake(kScreenWidth/2, kCellHeight)];
        
        [okAddButton autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [okAddButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:cancelAddButton];
        [okAddButton autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:cancelAddButton];
        [okAddButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:cancelAddButton];
        
        [self.addProgressPickerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.addProgressPickerView autoSetDimension:ALDimensionHeight toSize:kCellHeight*5];
    }
    return _addBackView;
}

- (UIPickerView *)addProgressPickerView
{
    if (!_addProgressPickerView) {
        _addProgressPickerView = [UIPickerView newAutoLayoutView];
        _addProgressPickerView.backgroundColor = kWhiteColor;
        _addProgressPickerView.showsSelectionIndicator = YES;
        _addProgressPickerView.delegate = self;
        _addProgressPickerView.dataSource = self;
        _addProgressPickerView.layer.borderColor = kBorderColor.CGColor;
        _addProgressPickerView.layer.borderWidth = kLineWidth;
    }
    return _addProgressPickerView;
}

- (NSMutableDictionary *)addPaceDic
{
    if (!_addPaceDic) {
        _addPaceDic = [NSMutableDictionary dictionary];
    }
    return _addPaceDic;
}

- (NSMutableArray *)evaImageArray
{
    if (!_evaImageArray) {
        _evaImageArray = [NSMutableArray array];
    }
    return _evaImageArray;
}
- (NSMutableArray *)addDataArray
{
    if (!_addDataArray) {
        _addDataArray = [NSMutableArray array];
    }
    return _addDataArray;
}

#pragma mark - delegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 80;
        }
        return 50+kBigPadding*2;
    }
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//EditDebtAddressCell.h
            identifier = @"addProgress00";
            EditDebtAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[EditDebtAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.ediLabel setHidden:YES];
            cell.leftTextViewConstraints.constant = kBigPadding;
            
            cell.ediTextView.placeholder = @"请输入进度详情";
            
            QDFWeakSelf;
            [cell setTouchBeginPoint:^(CGPoint point) {
                weakself.touchPoint = point;
            }];
            
            [cell setDidEndEditing:^(NSString *text) {
                [weakself.addPaceDic setValue:text forKey:@"memo"];
            }];
            
            return cell;

        }
        
        identifier = @"addProgress01";
        TakePictureCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[TakePictureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.collectionDataList = [NSMutableArray arrayWithObjects:@"upload_pictures", nil];
        
        QDFWeakSelf;
        QDFWeak(cell);
        [cell setDidSelectedItem:^(NSInteger itemTag) {
            if (itemTag == weakcell.collectionDataList.count-1) {//只允许点击最后一个collection
                if (weakcell.collectionDataList.count < 3) {
                    [weakself addImageWithMaxSelection:1 andMutipleChoise:YES andFinishBlock:^(NSArray *images) {

                        if (images.count > 0) {
                            NSData *imData = [NSData dataWithContentsOfFile:images[0]];
                            NSString *imString = [NSString stringWithFormat:@"%@",imData];
                            [weakself uploadImages:imString andType:@"jgp" andFilePath:images[0]];
                            
                            [weakself setDidGetValidImage:^(ImageModel *imageModel) {
                                if ([imageModel.error isEqualToString:@"0"]) {
                                    [weakself.evaImageArray addObject:imageModel.fileid];
                                    
                                    [weakcell.collectionDataList insertObject:images[0] atIndex:0];
                                    [weakcell reloadData];
                                }else{
                                    [weakself showHint:imageModel.msg];
                                }
                            }];
                        }
                    }];
                }else{
                    [weakself showHint:@"最多添加2张图片"];
                }
            }else{
                UIAlertController *alertContr = [UIAlertController alertControllerWithTitle:@"" message:@"确认删除该图片" preferredStyle:0];
                UIAlertAction *acty1 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [weakself.evaImageArray removeObjectAtIndex:itemTag];
                    [weakcell.collectionDataList removeObjectAtIndex:itemTag];
                    [weakcell reloadData];
                    
                }];
                UIAlertAction *acty0 = [UIAlertAction actionWithTitle:@"否" style:0 handler:nil];
                [alertContr addAction:acty0];
                [alertContr addAction:acty1];
                
                [weakself presentViewController:alertContr animated:YES completion:nil];
            }
        }];
        
        return cell;
    }else if (indexPath.section == 1){
        identifier = @"addProgress1";
        AgentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[AgentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.agentTextField.userInteractionEnabled = NO;
        cell.agentButton.userInteractionEnabled = NO;
        
        cell.agentLabel.text = @"进度类型";
        cell.agentTextField.placeholder = @"请选择处置类型";
        [cell.agentButton setImage:[UIImage imageNamed:@"list_more"] forState:0];
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kBigPadding;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getProgressList];
//    if (indexPath.section == 1) {
//        NSArray *uiuiui = @[@"留言",@"清收",@"查封",@"材料复合",@"产调",@"实地评估"];
//        
//        QDFWeakSelf;
//        [self showBlurInView:self.view withArray:uiuiui andTitle:@"选择进度类型" finishBlock:^(NSString *text, NSInteger row) {
//            AgentCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
//            cell.agentTextField.text = text;
//            
//            NSString *tttt = [NSString stringWithFormat:@"%d",row-1];
//            [weakself.addPaceDic setValue:tttt forKey:@"type"];
//        }];
//    }
}

#pragma mark - pickerview delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.addDataArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel *lanel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCellHeight)];
    lanel.font = kFirstFont;
    lanel.textAlignment = 1;
    
    AddProgressModel *addProgressModel = self.addDataArray[row];
    lanel.text = addProgressModel.name;
    if ([addProgressModel.disabled integerValue] == 0) {
        lanel.textColor = kBlackColor;
    }else{
        lanel.textColor = UIColorFromRGB(0xbbbbbb);
    }
    
    return lanel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    AddProgressModel *addProgressModel = self.addDataArray[row];
    if ([addProgressModel.disabled integerValue] == 1) {
        [pickerView selectRow:0 inComponent:0 animated:YES];
        addProgressModel = self.addDataArray[0];
    }
    
    [self.addPaceDic setValue:addProgressModel.ID forKey:@"type"];
    [self.addPaceDic setValue:addProgressModel.name forKey:@"name"];
}

#pragma mark - method
- (void)showAddPickerView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.addBackView];
    
    [self.addBackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)hiddenAddPickerView
{
    [self.addBackView removeFromSuperview];
}

- (void)getProgressList
{
    [self.view endEditing:YES];
    NSString *progressString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kMyOrderOfAddProgressString];
    NSDictionary *params = @{@"token" : [self getValidateToken],
                                    @"ordersid" : self.ordersid};
    
    QDFWeakSelf;
    [self requestDataPostWithString:progressString params:params successBlock:^(id responseObject) {
        
        AddProgressResponse *response = [AddProgressResponse objectWithKeyValues:responseObject];
        
        if ([response.code isEqualToString:@"0000"]) {
            for (AddProgressModel *model in response.actions) {
                [weakself.addDataArray addObject:model];
            }
            [weakself.addProgressPickerView reloadAllComponents];
            [weakself showAddPickerView];
        }else{
            [weakself showHint:response.msg];
        }
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (void)rightItemAction
{
    [self.view endEditing:YES];
    NSString *addPaceString = [NSString stringWithFormat:@"%@%@",kQDFTestUrlString,kMyOrderDetailOfAddPace];
    
    NSString *imageStr = @"";
    if (self.evaImageArray.count > 0) {
        for (NSInteger i=0; i<self.evaImageArray.count; i++) {
            imageStr = [NSString stringWithFormat:@"%@,%@",self.evaImageArray[i],imageStr];
        }
        imageStr = [imageStr substringToIndex:imageStr.length-1];
    }
    [self.addPaceDic setValue:imageStr forKey:@"file"];
    
    [self.addPaceDic setValue:[self getValidateToken] forKey:@"token"];
    [self.addPaceDic setValue:self.ordersid forKey:@"ordersid"];
    self.addPaceDic[@"type"] = self.addPaceDic[@"type"]?self.addPaceDic[@"type"]:@"";
    
    NSDictionary *params = self.addPaceDic;
    
    QDFWeakSelf;
    [self requestDataPostWithString:addPaceString params:params successBlock:^(id responseObject) {
        BaseModel *baseModel = [BaseModel objectWithKeyValues:responseObject];
        [weakself showHint:baseModel.msg];
        
        if ([baseModel.code isEqualToString:@"0000"]) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    } andFailBlock:^(NSError *error) {
        
    }];
}

- (void)back{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"放弃保存？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *act00 = [UIAlertAction actionWithTitle:@"否" style:0 handler:nil];
    
    QDFWeakSelf;
    UIAlertAction *act11 = [UIAlertAction actionWithTitle:@"是" style:0 handler:^(UIAlertAction * _Nonnull action) {
        [weakself.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertCon addAction:act00];
    [alertCon addAction:act11];
    
    [self presentViewController:alertCon animated:YES completion:nil];
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
