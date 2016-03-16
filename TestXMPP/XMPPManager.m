//
//  XMPPManager.m
//  TestXMPP
//
//  Created by 王春平 on 16/2/23.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "XMPPManager.h"

//枚举
typedef NS_ENUM(NSInteger, ConnectToServerPurpose) {
    ConnectToServerPurposeRegister,
    ConnectToServerPurposeLogin
};

@interface XMPPManager ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) ConnectToServerPurpose connectToServerPurpose;
@property (nonatomic, strong) XMPPJID *fromJID;

@end

@implementation XMPPManager

+ (XMPPManager *)shareManager {
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //创建通信通道对象
        self.xmppStream = [[XMPPStream alloc] init];
        //设置服务器IP地址
        self.xmppStream.hostName = KHostName;
        //设置服务器端口
        self.xmppStream.hostPort = KHostPort;
        //设置代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //创建好友花名册数据存储对象
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        //创建好友花名册管理对象
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信通道对象
        [self.xmppRoster activate:self.xmppStream];
        //设置代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //创建信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage *coreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        //创建信息归档对象
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:coreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信通道
        [self.xmppMessageArchiving activate:self.xmppStream];
        //创建数据管理器
        self.managedObjectContext = coreDataStorage.mainThreadManagedObjectContext;
    }
    return self;
}

//登录方法
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password {
    self.connectToServerPurpose = ConnectToServerPurposeLogin;
    self.password = password;
    //连接服务器
    [self connectToServerWIthUserName:userName];
}

//注册方法
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password {
    self.connectToServerPurpose = ConnectToServerPurposeRegister;
    self.password = password;
    //连接服务器
    [self connectToServerWIthUserName:userName];
}

//连接服务器
- (void)connectToServerWIthUserName:(NSString *)userName {
    //创建XMPPJID对象
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    //设置通信通道对象的JID
    self.xmppStream.myJID = jid;
    
    //发送请求
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        //先发送下线状态
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
        
        //断开连接
        [self.xmppStream disconnect];
    }
    //向服务器发送请求
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    if (error) {
        NSLog(@"%s__%d__%@| 连接失败", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
}

//连接超时方法
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"%s__%d__|连接超时", __FUNCTION__, __LINE__);
}

//连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    //连接成功后验证密码
    if (ConnectToServerPurposeLogin == self.connectToServerPurpose) {
        [self.xmppStream authenticateWithPassword:self.password error:nil];
    } else {
        [self.xmppStream registerWithPassword:self.password error:nil];
    }
}

//收到好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    self.fromJID = presence.from;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.fromJID];
            break;
        case 1:
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJID andAddToRoster:YES];
            break;
        default:
            break;
    }
}

@end
