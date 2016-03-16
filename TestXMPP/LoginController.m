//
//  LoginController.m
//  TestXMPP
//
//  Created by 王春平 on 16/2/23.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加代理
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    [[XMPPManager shareManager] loginWithUserName:self.userNameTextField.text password:self.passwordTextField.text];
}

//验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"%s__%d__登录成功", __FUNCTION__, __LINE__);
    //发送上线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager shareManager].xmppStream sendElement:presence];
    [self performSegueWithIdentifier:@"roster" sender:nil];
}

//登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"%s__%d__| 登录失败", __FUNCTION__, __LINE__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && self.view.window) {
        self.view = nil;
    }
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
