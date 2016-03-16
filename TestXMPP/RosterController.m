//
//  RosterController.m
//  TestXMPP
//
//  Created by 王春平 on 16/2/24.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "RosterController.h"

@interface RosterController ()<XMPPRosterDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation RosterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [NSMutableArray arrayWithCapacity:1];
    self.title = [XMPPManager shareManager].xmppStream.myJID.user;
    [[XMPPManager shareManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//开始检索好友
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    NSLog(@"%s__%d__| 开始检索好友", __FUNCTION__, __LINE__);
}

//检索到好友
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item {
    //取jid字符串
    NSString *jidString = [[item attributeForName:@"jid"] stringValue];
    //创建JID对象
    XMPPJID *jid = [XMPPJID jidWithString:jidString];
    //把jid添加到数组中
    if ([self.dataSource containsObject:jid]) {
        return;
    }
    [self.dataSource addObject:jid];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//检索好友结束
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"%s__%d__| 检索好友结束", __FUNCTION__, __LINE__);
}

- (IBAction)addFriendAction:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加好友" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
        {
            UITextField *testField = [alertView textFieldAtIndex:0];
            XMPPJID *jid = [XMPPJID jidWithUser:testField.text domain:kDomin resource:kResource];
            [[XMPPManager shareManager].xmppRoster addUser:jid withNickname:nil];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell" forIndexPath:indexPath];
    //取出数组中的JID对象，给cell赋值
    XMPPJID *jid = self.dataSource[indexPath.row];
    cell.textLabel.text = jid.user;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatController *chatVC = segue.destinationViewController;
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    XMPPJID *jid = self.dataSource[indexPath.row];
    chatVC.friendJID = jid;
}

@end
