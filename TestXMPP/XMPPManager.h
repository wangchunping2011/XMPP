//
//  XMPPManager.h
//  TestXMPP
//
//  Created by 王春平 on 16/2/23.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPManager : NSObject<XMPPStreamDelegate, XMPPRosterDelegate>

//通信通道对象
@property (nonatomic, strong) XMPPStream *xmppStream;
//好友花名册管理对象
@property (nonatomic, strong) XMPPRoster *xmppRoster;
//信息归档对象
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;
//创建数据管理器
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


+ (XMPPManager *)shareManager;
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password;
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password;

@end
