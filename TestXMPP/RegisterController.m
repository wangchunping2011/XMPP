//
//  RegisterController.m
//  TestXMPP
//
//  Created by 王春平 on 16/2/23.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "RegisterController.h"

@interface RegisterController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)registerButtonAction:(UIButton *)sender {
    [[XMPPManager shareManager] registerWithUserName:self.userNameTextField.text password:self.passwordTextField.text];
}

//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"%s__%d__| 注册成功", __FUNCTION__, __LINE__);
    [self.navigationController popViewControllerAnimated:YES];
}

//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"%s__%d__| 注册失败", __FUNCTION__, __LINE__);
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
