//
//  GTSSelfInformationVCViewController.m
//  SmartHome
//
//  Created by 周宇航 on 16/5/9.
//  Copyright © 2016年 gtscn. All rights reserved.
//
#import "SCSelfInformationVC.h"


//#import "SCReFindPwdVC.h"
#import "UIColor+Util.h"
#import "ZYRadioButton.h"

#import "UIImage+ImageEffects.h"

@interface SCSelfInformationVC () <RadioButtonDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate,UITextFieldDelegate> {
    NSTimer *showLater;
    UIPopoverController *popoverVC;
    LPuserModel * userInformation;
    UITextField *userName;
}
@end

@implementation SCSelfInformationVC
static int num = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"actionBack"] style:UIBarButtonItemStyleDone target:self action:@selector(actionUpdateUserInfo)];

    self.tableView.sectionHeaderHeight = 20;

//    self.userInformation = [[GTSUserInformations alloc] init];
    [self actionGetUserInformation];
    //给表格添加一个尾部视图
    // self.tableView.tableFooterView = [self creatFootView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.tableView.backgroundColor = fRgbColor(250, 250, 250);
    num = 1;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    haveChangeUserSex=0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0:
        return 4;
        break;

    default:
        return 1;
        break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserFormCell"];
            if (cell == nil) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"UserFormCell" owner:nil options:nil].lastObject;
            }
            UILabel *LabName = (UILabel *)[cell viewWithTag:11001];
            LabName.text = @"头像";
            LabName.textColor = fRgbColor(79, 91, 28);
            LabName.font = [UIFont systemFontOfSize:13];

            UIImageView *headimage = (UIImageView *)[cell viewWithTag:11002];
            headimage.layer.cornerRadius = 15;
            headimage.contentMode=UIViewContentModeScaleAspectFill;
            headimage.layer.masksToBounds = YES;
            headimage.layer.borderColor = BACKCOLOR.CGColor;
            headimage.layer.borderWidth = 0.5;
            
            //
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *pictureName= @"UserPortrait.png";
            NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
            //从手机本地加载图片
            UIImage *pushImage = [[UIImage alloc]initWithContentsOfFile:savedImagePath];
            
            [headimage sd_setImageWithURL:[NSURL URLWithString:self.userInformation.imageStr] placeholderImage:pushImage];
            UILabel *LabNil = (UILabel *)[cell viewWithTag:11003];
            LabNil.hidden = YES;
            break;
        }
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserFormCell"];
            if (cell == nil) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"UserFormCell" owner:nil options:nil].lastObject;
            }
            UILabel *LabName = (UILabel *)[cell viewWithTag:11001];
            LabName.text = @"昵称";
            LabName.textColor = fRgbColor(79, 91, 28);
            LabName.font = [UIFont systemFontOfSize:13];

            UILabel *LabUserName = (UILabel *)[cell viewWithTag:11003];
            NSString * name=self.userInformation.userName;
            if (name.length==0||[name isEqualToString:@"(null)"]) {
                name=@"";
            }
            LabUserName.text = name;
            LabUserName.textColor = fRgbColor(128, 128, 128);
            LabUserName.font = [UIFont systemFontOfSize:13];

            UIImageView *headimage = (UIImageView *)[cell viewWithTag:11002];
            headimage.hidden = YES;
            break;
        }
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserFormCell"];
            if (cell == nil) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"UserFormCell" owner:nil options:nil].lastObject;
            }
            UILabel *LabName = (UILabel *)[cell viewWithTag:11001];
            LabName.text = @"手机号";
            LabName.textColor = fRgbColor(79, 91, 28);
            LabName.font = [UIFont systemFontOfSize:13];

            UILabel *LabUserGSNumber = (UILabel *)[cell viewWithTag:11003];
            // LabUserGSNumber.text = self.userInformation.userGSNumber;

            NSString *tel = [[AVUser currentUser].mobilePhoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            LabUserGSNumber.text = tel;
            LabUserGSNumber.textAlignment = NSTextAlignmentRight;
            LabUserGSNumber.textColor = fRgbColor(128, 128, 128);
            LabUserGSNumber.font = [UIFont systemFontOfSize:13];

            UIImageView *headimage = (UIImageView *)[cell viewWithTag:11002];
            headimage.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 3: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserRadioCell"];
            if (cell == nil) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"UserRadioCell" owner:nil options:nil].lastObject;
            }
            UILabel *LabName = (UILabel *)[cell viewWithTag:12001];
            LabName.text = @"性别";
            LabName.textColor = fRgbColor(79, 91, 28);
            LabName.font = [UIFont systemFontOfSize:13];
            //定义单选按钮
            ZYRadioButton *RBMan = [[ZYRadioButton alloc] initWithGroupId:@"first group" index:0 size:CGSizeMake(48, 25)];
            ZYRadioButton *RBWoman = [[ZYRadioButton alloc] initWithGroupId:@"first group" index:1 size:CGSizeMake(48, 25)];
            [cell addSubview:RBMan];
            [RBMan handleTitle:@"男"];
            [cell addSubview:RBWoman];
            [RBWoman handleTitle:@"女"];

            //按照GroupId添加观察者
            [ZYRadioButton addObserverForGroupId:@"first group" observer:self];

            [RBMan mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.mas_centerY);
                make.right.equalTo(RBWoman.mas_left).with.offset(-20);
                make.width.mas_equalTo(@58);
                make.height.mas_equalTo(@35);
            }];
            [RBWoman mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.mas_centerY);
                make.right.equalTo(cell.mas_right).with.offset(-20);
                make.width.mas_equalTo(@58);
                make.height.mas_equalTo(@35);
            }];
            //
            if ([self.userInformation.userSex integerValue] == 1) {
                [RBWoman setButtonState];

            } else if ([self.userInformation.userSex integerValue] == 0) {
                [RBMan setButtonState];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 7: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserFormCell"];
            if (cell == nil) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"UserFormCell" owner:nil options:nil].lastObject;
            }
            UILabel *LabName = (UILabel *)[cell viewWithTag:11001];
            LabName.text = @"地区";
            UILabel *LabUserArea = (UILabel *)[cell viewWithTag:11003];
            LabUserArea.text = self.userInformation.userArea;

            UIImageView *headimage = (UIImageView *)[cell viewWithTag:11002];
            headimage.hidden = YES;

            break;
        }

        case 4: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserFormCell"];
            if (cell == nil) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"UserFormCell" owner:nil options:nil].lastObject;
            }
            UILabel *LabName = (UILabel *)[cell viewWithTag:11001];
            LabName.text = @"修改密码";
            UILabel *LabNil = (UILabel *)[cell viewWithTag:11002];
            LabNil.hidden = YES;
            UIImageView *headimage = (UIImageView *)[cell viewWithTag:11003];
            headimage.hidden = YES;

            break;
        }

        default:
            break;
        }

        break;
    }

    case 1: {

        cell = [tableView dequeueReusableCellWithIdentifier:@"UserFormCell"];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"UserFormCell" owner:nil options:nil].lastObject;
        }
        UILabel *LabName = (UILabel *)[cell viewWithTag:11001];
        LabName.text = @"实名认证(开发中)";
        UILabel *LabNil = (UILabel *)[cell viewWithTag:11002];
        LabNil.hidden = YES;
        UIImageView *headimage = (UIImageView *)[cell viewWithTag:11003];
        headimage.hidden = YES;
        break;
    }
    default:
        break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {
            [self actionChangeUserHeadimage];

            break;
        }
        case 1: {
            [self actionChangeUserName];

            break;
        }
        case 2: {

            [self actionChangeUserGSNumber];

            break;
        }
        case 3: {

            [self actionChangeUserSex];

            break;
        }
        case 5: {

            [self actionChangeUserArea];
            break;
        }
        case 4: {

            [self actionChangeUserPwd];

            break;
        }

        default:
            break;
        }

        break;
    }

    case 1: {
        [self actionChangeUserInformation];
        [self.tableView reloadData];
        break;
    }
    default:
        break;
    }
}

#pragma mark UIAlertViewDeleage
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
    case 0:
        break;
    case 1: {
        // 读取文本框的值显示出来
        UITextField *txtUserName = [alertView textFieldAtIndex:0];
        self.userInformation.userName = txtUserName.text;
        [self.tableView reloadData];
        break;
    }

    default:
        break;
    }
}

//推退出登录
- (UIView *)creatFootView {

    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGTSDeviceWidth, 60)];

    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.layer.cornerRadius = 5;
    btnExit.layer.masksToBounds = YES;
    [btnExit setTitle:@"退出登录" forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(actionLogout) forControlEvents:UIControlEventTouchUpInside];
    btnExit.backgroundColor = BACKCOLOR;
    [btnExit setTintColor:[UIColor whiteColor]];
    btnExit.titleLabel.font = [UIFont systemFontOfSize:20];

    [footView addSubview:btnExit];
    [btnExit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(footView.mas_centerX);
        make.centerY.equalTo(footView.mas_centerY);
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(36);
    }];

    return footView;
}

#pragma mark -cell点击事件
- (void)actionChangeUserHeadimage {
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_addButtonWithTitle:@"拍照"
                               handler:^{
                                   selectPhotoType = 1;
                                   [weakSelf getImgFromCamera];
                               }];
    [actionSheet bk_addButtonWithTitle:@"从手机相册选择"
                               handler:^{
                                   selectPhotoType = 2;
                                   [weakSelf getHeadImage];

                               }];
    [actionSheet bk_addButtonWithTitle:@"取消"
                                     handler:^{
                                         selectPhotoType = 0;
                                     }];

    [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger buttonIndex) {
        if (selectPhotoType == 1) {

        } else if (selectPhotoType == 2) {
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)actionChangeUserName {
    [self doAlertInput:@"修改昵称" andPlaceholder:nil];
}

- (void)actionChangeUserGSNumber {
     [self.view makeToast:@"手机号不可修改" duration:2 position:CSToastPositionBottom];
}

- (void)actionChangeUserSex {
}

- (void)actionChangeUserArea {
}

- (void)actionChangeUserPwd {

//    UIStoryboard *addDeviceStoryBoard = [UIStoryboard storyboardWithName:@"SCReLoginSB" bundle:nil];
//    SCReFindPwdVC *vc = [addDeviceStoryBoard instantiateViewControllerWithIdentifier:@"SCReFindPwdVC"];
//    vc.type = 4;
//    vc.titleName = @"修改密码";
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionChangeUserInformation {
}

- (void)actionLogout {
   
}

- (void)actionGetUserInformation {
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * userDic= [userDef objectForKey:@"userInfomation" ];
    NSString *strImage = [userDic objectForKey:@"headIcon"];
    [self.userInformation.userHeadimage sd_setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"DefaultHeadImage"]];
    self.userInformation.imageStr=strImage;
    self.userInformation.userSex = (NSNumber *)[userDic objectForKey:@"gender"];
    self.userInformation.userName = (NSString *)[userDic objectForKey:@"nickName"];
    self.userInformation.userArea = (NSString *)[userDic objectForKey:@"city"];
    [self.tableView reloadData];
    
    
//    AVUser *user = [AVUser currentUser];
//    [user fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//        [AVUser changeCurrentUser:(AVUser *)object save:YES];
//    
//    
////        NSDictionary *dic = @{@"uid":[AVUser currentUser].objectId
////                              };
////        [SCADeviceService getEntrepreneurialCenterMsg:dic completion:^(id result,NSError *error)
////         {
////             NSDictionary * userDic;
////             if (error) {
////                 NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
////                 userDic= [userDef objectForKey:@"userInfomation" ];
////                   [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionBottom];
////             }else{
////                 userDic=[NSDictionary dictionaryWithDictionary:result];
////             }
////             NSString *strImage = [[AVUser currentUser] objectForKey:@"headIcon"];
////             [self.userInformation.userHeadimage sd_setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"DefaultHeadImage"]];
////             self.userInformation.imageStr=strImage;
////             self.userInformation.userSex = (NSNumber *)[[AVUser currentUser] objectForKey:@"gender"];
////             self.userInformation.userName = (NSString *)[[AVUser currentUser] objectForKey:@"nickName"];
////             self.userInformation.userArea = (NSString *)[[AVUser currentUser] objectForKey:@"city"];
////             num=1;
////             [self.tableView reloadData];
////         }];
//        
//        }];
}

- (void)actionUpdateUserInfo {
    
    //    if (self.userInformation.userName.length <= 0) {
    //        [self.view makeToast:@"请填写昵称" duration:2.0 position:CSToastPositionCenter];
    //        return;
    //    }
    //判断只有图片有修改才需要上传图片
//    if (!haveChangeUserImg) {
//        [self.navigationController popViewControllerAnimated:NO];
//        return;
//    }
//    
    //    [SVProgressHUD showWithStatus:@"正在保存..."];
//    NSData *dataImage = UIImageJPEGRepresentation(self.userInformation.userHeadimage.image, 0.5);
//    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self) weakSelf = self;
    
    [SCADeviceService editUserInfoWithName:self.userInformation.userName gender:self.userInformation.userSex avatar:nil completion:^(id result, NSError *error) {
        if (!error) {
            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary * userDic= [userDef objectForKey:@"userInfomation" ];
            NSMutableDictionary * changeDic=[NSMutableDictionary dictionaryWithDictionary:userDic];
            [changeDic setObject:self.userInformation.userName forKey:@"nickName"];
            [changeDic setObject:self.userInformation.userSex forKey:@"gender"];
            [userDef setObject:changeDic forKey:@"userInfomation"];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"backImage" object:nil userInfo:@{@"user":@1}];
            //[self.navigationController popViewControllerAnimated:NO];
        }else{
            [weakSelf.view makeToast:[NSString stringWithFormat:@"保存失败:%@", error.localizedDescription] duration:2 position:CSToastPositionTop];
        }
    }];

    
    //异步执行队列任务
//    dispatch_async(globalQueue, ^{
//        AVFile *file = [AVFile fileWithData:dataImage];
//        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            //             [SVProgressHUD dismiss];
//            if (succeeded) {
//                [[AVUser currentUser] setObject:weakSelf.userInformation.userName forKey:@"nickName"];
//                [[AVUser currentUser] setObject:weakSelf.userInformation.userArea forKey:@"city"];
//                [[AVUser currentUser] setObject:weakSelf.userInformation.userSex forKey:@"gender"];
//                [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    if (succeeded) {
//                        // [self.view makeToast:@"保存成功" duration:2 position:CSToastPositionTop];
//                        [self  saveUserPortrait:[[AVUser currentUser] objectForKey:@"avatar"]];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"backImage" object:nil userInfo:@{@"user":@1}];
//                        [self.navigationController popViewControllerAnimated:NO];
//                    } else {
//                        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"保存失败:%@", error]];
//                    }
//                }];
//            }else {
//                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"保存失败:%@", error]];
//            }
//        }
//                          progressBlock:^(NSInteger percentDone) {
//                              
//                          }];
//        
//    });
}

-(void)changeHeadImageSaveCompletion:(SHResultObjectBlock)completion{
    NSData *dataImage = UIImageJPEGRepresentation(self.userInformation.userHeadimage.image, 0.5);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_async(globalQueue, ^{
        
    });
    
        //        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            [SVProgressHUD dismiss];
//            if (succeeded) {
//                [[AVUser currentUser] setObject:file.url forKey:@"avatar"];
//                if (succeeded) {
//                    self.userInformation.imageStr=file.url;
//                    [weakSelf.view makeToast:@"保存成功" duration:2 position:CSToastPositionTop];
//                    [weakSelf  saveUserPortrait:[[AVUser currentUser] objectForKey:@"avatar"]];
//                    [self.tableView reloadData];

//                } else {
//                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"保存失败:%@", error.localizedDescription]];
//                }
//            } else {
//                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"保存失败:%@", error.localizedDescription]];
//            }
//        } progressBlock:^(NSInteger percentDone) {
//            
//        }];
    
}


#pragma mark - 修改框
- (void)doAlertInput:(NSString *)Title andPlaceholder:(NSString *)placeholder {

    if (kGTSiOSVersionFirstValue >= 8) {
        // 初始化
        UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:Title message:nil preferredStyle:UIAlertControllerStyleAlert];

        // 创建文本框
        [alertDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if(self.userInformation.userName){
                 textField.text=self.userInformation.userName;
            }else{
                textField.placeholder =@"昵称在2~12个字之间";//
            }
            textField.delegate=self;
            textField.secureTextEntry = NO;
        }];

        // 创建操作
        // UIAlertViewStyle
        //
        UIAlertAction *ChangeAlert = [UIAlertAction actionWithTitle:@"确认"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                // 读取文本框的值显示出来
                                                                userName = alertDialog.textFields.firstObject;
                                                                userName.delegate = self;
                                                                if ([self judgeNameQualified:userName.text]) {
                                                                    self.userInformation.userName = userName.text;
                                                                    [self actionUpdateUserInfo];
                                                                    [self.tableView reloadData];
                                                                } else {
                                                                    [self actionChangeUserName];
                                                                }

                                                            }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action){

                                                       }];

        // 添加操作（顺序就是呈现的上下顺序）
        [alertDialog addAction:ChangeAlert];
        [alertDialog addAction:cancle];
        // 呈现警告视图
        [self presentViewController:alertDialog animated:YES completion:nil];
    } else {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];

        UITextField *nameField = [alertView textFieldAtIndex:0];
        nameField.placeholder = @"请输入昵称";

        [alertView show];
    }
}

- (int)judgeNameQualified:(NSString *)nickName {
    if (nickName.length < 1) {
        [self.view makeToast:@"昵称不可为空" duration:2.0 position:CSToastPositionTop];
        return 0;
    }else if (nickName.length <2||nickName.length >12) {
        [self.view makeToast:@"昵称在2~12个字之间" duration:2.0 position:CSToastPositionTop];
        return 0;
    }
    NSString *first = [nickName substringToIndex:1];

    if ([first isEqualToString:@" "]) {
        [self.view makeToast:@"昵称第一位不可为空格" duration:2.0 position:CSToastPositionTop];
        return 0;
    }
    NSString *last = [nickName substringFromIndex:nickName.length - 1];

    if ([last isEqualToString:@" "]) {
        [self.view makeToast:@"昵称最后一位不可为空格" duration:2.0 position:CSToastPositionTop];
        return 0;
    }

    return 1;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([textField isEqual:userName]||[textField isEqual:userName]) {
        if (range.location >= 12) {
            //[self.view makeToast:@"昵称在2~12个字之间" duration:2.0 position:CSToastPositionTop];
            return NO;
        }
//    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length > 12) {
        [self.view makeToast:@"昵称在2~12个字之间" duration:2.0 position:CSToastPositionTop];
        [self actionChangeUserName];
    }
    
}

#pragma mark -获取照片相册/拍照

- (void)getImgFromCamera {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    // imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:(NSString *)kCIAttributeTypeImage, nil];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//获取相册照片（以下3个方法）
- (void)getHeadImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound) { //如果是ipad
            popoverVC = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
            popoverVC.delegate = self;
            [popoverVC presentPopoverFromRect:CGRectMake(0, 0, 120, 200) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self presentViewController:imgPicker animated:YES completion:nil];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"访问手机相册异常" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    [popover dismissPopoverAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    haveChangeUserImg = 1; //修改过图片了
    [picker dismissViewControllerAnimated:YES completion:nil];
    [popoverVC dismissPopoverAnimated:YES];
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑过的
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    self.userInformation.userHeadimage = [[UIImageView alloc] initWithImage:img];
    [self changeHeadImageSaveCompletion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -单选按钮的代理方法
//单选按钮的代理方法
- (void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId {

    self.userInformation.userSex = [NSNumber numberWithInteger:index];
    if (haveChangeUserSex) {
        num = 0;
        __weak typeof(self) weakSelf = self;
        
        [SCADeviceService editUserInfoWithName:nil gender:weakSelf.userInformation.userSex avatar:nil completion:^(id result, NSError *error) {
            if (!error) {
                
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                NSDictionary * userDic= [userDef objectForKey:@"userInfomation" ];
                NSMutableDictionary * changeDic=[NSMutableDictionary dictionaryWithDictionary:userDic];
                [changeDic setObject:self.userInformation.userSex forKey:@"gender"];
                [userDef setObject:changeDic forKey:@"userInfomation"];
                
                [weakSelf.view makeToast:@"保存成功" duration:2 position:CSToastPositionTop];
                [weakSelf.tableView reloadData];
            }else{
                [weakSelf.view makeToast:[NSString stringWithFormat:@"保存失败:%@", error.localizedDescription] duration:2 position:CSToastPositionTop];
            }
        }];

        
//        [[AVUser currentUser] setObject:weakSelf.userInformation.userName forKey:@"nickName"];
//        [[AVUser currentUser] setObject:weakSelf.userInformation.userSex forKey:@"gender"];
//        [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [self.view makeToast:@"保存成功!" duration:1.5 position:CSToastPositionCenter];
//
//            } else {
//                [self filterError:error];
//            }
//
//        }];
    }
    haveChangeUserSex=1;
}

-(void)saveUserPortrait:(NSString *)url
{
    UIImage *sendImage = [[self getImageFromURL:url] blurImageWithRadius:3];
    
    NSData *imageViewData = UIImagePNGRepresentation(sendImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pictureName= @"UserPortrait.png";
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
    [imageViewData writeToFile:savedImagePath atomically:YES];//保存照片到沙盒目录
}


- (UIImage *)getImageFromURL:(NSString *)fileURL {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    if ([data length] == 0) {
        return [UIImage imageNamed:@"User-DefaultHeadImage"];
    }
    [self reduceImage:[UIImage imageWithData:data] percent:0.1];
    
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]]];
}

//压缩图片质量
- (UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}



//压缩图片
+ (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    // Get the new image from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

@end
