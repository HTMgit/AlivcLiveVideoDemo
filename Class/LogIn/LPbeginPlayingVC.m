//
//  LPbeginPlayingVC.m
//  AlivcLiveVideoDemo
//
//  Created by zyh on 2017/10/11.
//  Copyright © 2017年 Alibaba Video Cloud. All rights reserved.
//

#import "LPbeginPlayingVC.h"

#import "LPloginVC.h"
#import "SCSelfInformationVC.h"
#import "AlivcLiveViewController.h"

@interface LPbeginPlayingVC ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIPopoverControllerDelegate,UIActionSheetDelegate>{
    float keyWordHight;
    BOOL isKeyShow;
    BOOL isMove;//是否需要移动添加框
    UIPopoverController *popoverVC;
    LPuserModel * userInfo;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgShow;
@property (weak, nonatomic) IBOutlet UIButton *btnBegin;
@property (weak, nonatomic) IBOutlet UILabel *labRoomDetail;
@property (weak, nonatomic) IBOutlet UITextView *txtRoomDetail;

@end

@implementation LPbeginPlayingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"直播大厅";
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    UIButton * btnSet =[[UIButton alloc]init];
    [btnSet setImage:[UIImage imageNamed:@"m_set"] forState:UIControlStateNormal];
    btnSet.frame = CGRectMake(0, 0, 25, 25);
    [btnSet addTarget:self action:@selector(actionTurnToUserInfomation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn =[[UIBarButtonItem alloc]initWithCustomView:btnSet];
     self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dicUserInfo = [userDefaults objectForKey:@"userInfo"];
    NSError * transforError ;
    userInfo = [LPuserModel arrayOfModelsFromDictionaries:@[dicUserInfo] error:&transforError].lastObject;
    [_imgShow sd_setImageWithURL:[NSURL URLWithString:userInfo.frontUrl] placeholderImage:[UIImage imageNamed:@"roomDef"]];
    
    _txtRoomDetail.delegate = self;
    if ([dicUserInfo.allKeys containsObject:@"brief"]) {
        NSString * briefStr =dicUserInfo[@"brief"];
        if (briefStr.length) {
            _txtRoomDetail.text = briefStr;
            _labRoomDetail.hidden = YES;
        }
    }
    if (!_txtRoomDetail.text.length) {
        _labRoomDetail.hidden = NO;
    }
    
    _btnBegin.layer.cornerRadius = 5;
    _btnBegin.layer.masksToBounds = YES;
    _btnBegin.layer.borderWidth = 1;
    _btnBegin.layer.borderColor = [UIColor orangeColor].CGColor;
    
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTxtResponder)];
    
    [self.view addGestureRecognizer:tap];
    [self addSureBtnOnKeyboardBar];
    [self registerForKeyboardNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBeginLivePlaying:(id)sender {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dicUserInfo = [userDefaults objectForKey:@"userInfo"];
    if (!dicUserInfo) {
        [ZYHCommonService showMakeToastView:@"未搜索到用户"];
    }else{
        
        NSError * transforError ;
        LPuserModel * userInfo = [LPuserModel arrayOfModelsFromDictionaries:@[dicUserInfo] error:&transforError].lastObject;
        NSString * url =[NSString stringWithFormat:@"/userc/live/push?vc=%@",userInfo.vc];
        NSString * requestUrl = [REQUESTURL stringByAppendingString:url];
        
        __weak typeof(self) weakSelf = self;
        [ZYHCommonService createASIFormDataRequset:requestUrl param:nil completion:^(id result, NSError *error) {
            if (error) {
                [ZYHCommonService showMakeToastView:error.localizedDescription];
            }else{
                NSDictionary * dicResult = [NSDictionary dictionaryWithDictionary:result];
                if([dicResult.allKeys containsObject:@"errmsg"]) {
                    [ZYHCommonService showMakeToastView:[NSString stringWithFormat:@"%@:%@",result[@"errmsg"],result[@"errcode"]]];
                    return ;
                }else if ([dicResult.allKeys containsObject:@"stream"]) {
                    AlivcLiveViewController *live = [[AlivcLiveViewController alloc] initWithNibName:@"AlivcLiveViewController" bundle:nil url:result[@"stream"] isScreenHorizontal:0];
                    live.emceeInfo = userInfo;
                    live.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController hidesBottomBarWhenPushed];
                    [weakSelf.navigationController pushViewController:live animated:YES];
                }else{
                    [ZYHCommonService showMakeToastView:@"推流地址不存在"];
                    return;
                }
            }
        }];
    }
}

- (IBAction)actionCutOutUser:(id)sender {
    
    if (self.navigationController.viewControllers.count <= 1) {
        LPloginVC *login = [[LPloginVC alloc] init];
        UINavigationController * nav =[[UINavigationController alloc]initWithRootViewController:login];
        [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

- (IBAction)actionChangeShowImg:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_addButtonWithTitle:@"拍照"
                               handler:^{
                                   [weakSelf getImgFromCamera];
                               }];
    [actionSheet bk_addButtonWithTitle:@"从手机相册选择"
                               handler:^{
                                   [weakSelf getHeadImage];
                                   
                               }];
    [actionSheet bk_addButtonWithTitle:@"取消"
                               handler:^{
                               }];
    
    [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger buttonIndex) {
        
    }];
    [actionSheet showInView:self.view];
}

- (IBAction)actionTurnToUserInfomation:(id)sender {
    SCSelfInformationVC *  userInfoVC = [[SCSelfInformationVC alloc]init];
    userInfoVC.hidesBottomBarWhenPushed  = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

//修改房间简介
-(void)actionChangeRoomDetail:(NSString *)detailStr{
    NSString * url =[NSString stringWithFormat:@"/userc/updateInfo?vc=%@",userInfo.vc];
    NSString * requestUrl = [REQUESTURL stringByAppendingString:url];
    [ZYHCommonService createASIFormDataRequset:requestUrl param:@{@"brief":detailStr} completion:^(id result, NSError *error) {
        if (error) {
            [ZYHCommonService showMakeToastView:[NSString stringWithFormat:@"昵称修改错误:%@",error.localizedDescription]];
        }else{
            
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary * dicUserInfo =[NSMutableDictionary dictionaryWithDictionary: [userDefaults objectForKey:@"userInfo"]];
            [dicUserInfo setObject:detailStr forKey:@"brief"];
            [userDefaults setObject:dicUserInfo forKey:@"userInfo"];
        }
    }];
}
//修改房间展示图片
-(void)actionChangeRoomShowImageSaveCompletion:(UIImage *)changeImage{
    
    NSString * url =[NSString stringWithFormat:@"/userc/updateImage?vc=%@",userInfo.vc];
    NSString * requestUrl = [REQUESTURL stringByAppendingString:url];
    
    NSData *data = UIImageJPEGRepresentation(changeImage, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [ZYHCommonService createASIFormDataRequset:requestUrl param:@{@"base64Data":encodedImageStr,@"type":@2} completion:^(id result, NSError *error) {
        if (error) {
            [ZYHCommonService showMakeToastView:[NSString stringWithFormat:@"封面修改错误:%@",error.localizedDescription]];
        }else{
            NSDictionary * dicResult =[NSDictionary dictionaryWithDictionary:result];
            if ([dicResult.allKeys containsObject:@"data"]) {
                userInfo.frontUrl = dicResult[@"data"];
                NSDictionary * dicUserInfo = [userInfo toDictionary];
                NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:dicUserInfo forKey:@"userInfo"];
                [_imgShow sd_setImageWithURL:[NSURL URLWithString:userInfo.frontUrl] placeholderImage:[UIImage imageNamed:@"roomDef"]];
            }else{
                [ZYHCommonService showMakeToastView:@"返回数据错误"];
            }
        }
    }];
    
}

#pragma mark 输入框
-(void)addSureBtnOnKeyboardBar{
    //定义一个toolBar
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
    
    //设置style
    [topView setBarStyle:UIBarStyleBlack];
    
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(changeTxtResponder)];
    [doneButton setTintColor:fRgbColor(60, 180, 240)];
    
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];
    [_txtRoomDetail setInputAccessoryView:topView];
}

- (void) registerForKeyboardNotifications{
    keyWordHight=0;
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    if (!keyboardSize.height) {
        return;
    }

    if (isKeyShow) {
        return;
    }
    isKeyShow=YES;
    NSLog(@"keyBoard:%f", keyboardSize.height);  //250

    float bottom =(kNMDeviceHeight - (400-44));
    if (bottom>320) {//keyboardSize.height
        isMove = NO;
    }else{
        isMove = YES;
    }

    if (!isMove) {
        return;
    }
    if(keyWordHight<=0){
        keyWordHight=320-bottom; //keyboardSize.height-bottom;
    }


    [UIView animateWithDuration:0.1
                     animations:^{
                         self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-keyWordHight, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
//
}

- (void) keyboardWasHidden:(NSNotification *) notif
{
    isKeyShow=NO;
    
    if (!isMove) {
        return;
    }
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+keyWordHight, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
    
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _labRoomDetail.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView.text.length) {
        _labRoomDetail.hidden = YES;
    }else{
        _labRoomDetail.hidden = NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:userInfo.brief]) {
        return;
    }else{
        [self actionChangeRoomDetail:textView.text];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
}

-(void)changeTxtResponder{
    [_txtRoomDetail resignFirstResponder];
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    [popoverVC dismissPopoverAnimated:YES];
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑过的
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * reduceImg =[self imageWithImageSimple:img scaledToSize:CGSizeMake(100, 100)];
    //userInformation.userHeadimage = [[UIImageView alloc] initWithImage:img];
    [self actionChangeRoomShowImageSaveCompletion:reduceImg];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//压缩图片质量
- (UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}

//压缩图片
- (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
