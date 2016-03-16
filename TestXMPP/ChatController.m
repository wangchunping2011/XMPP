//
//  ChatController.m
//  TestXMPP
//
//  Created by 王春平 on 16/2/25.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "ChatController.h"

@interface ChatController ()<XMPPStreamDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation ChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.messageArray = [NSMutableArray arrayWithCapacity:1];
    //给通信通道对象添加代理
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //检索信息
    [self reloadMessages];
}

- (void)reloadMessages {
    NSManagedObjectContext *managedObjectContext = [XMPPManager shareManager].managedObjectContext;
    //创建查询类
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //创建实体描述类
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:managedObjectContext];
    fetchRequest.entity = entityDescription;
    //创建谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@", self.friendJID.bare, [XMPPManager shareManager].xmppStream.myJID.bare];
    //创建排序类
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    //从临时数据库中查找聊天信息
    NSArray *fetchArray = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (fetchArray.count > 0) {
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:fetchArray];
        [self.tableView reloadData];
    }
    if (self.messageArray.count > 0) {
        //动画效果
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (IBAction)sendMessageAction:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"发送消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

//消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    [self reloadMessages];
}

//消息接收成功
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [self reloadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
            [message addBody:textField.text];
            [[XMPPManager shareManager].xmppStream sendElement:message];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
    if (message.isOutgoing) {
        MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMessageCell" forIndexPath:indexPath];
        cell.chatLabel.text = message.body;
        return cell;
        
    }
    FriendMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendMessageCell" forIndexPath:indexPath];
    cell.chatLabel.text = message.body;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
